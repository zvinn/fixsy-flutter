import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/security/token_vault.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/cache_manager.dart';
import '../models/user.dart';

/// Clean Implementation of IAuthRepository
/// Enforces Fixsy Constitution Principles I, II, & III.
class AuthRepositoryImpl implements IAuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final TokenVault _tokenVault;
  final CacheManager _cacheManager;

  AuthRepositoryImpl({
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    TokenVault? tokenVault,
    CacheManager? cacheManager,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _tokenVault = tokenVault ?? TokenVault(),
        _cacheManager = cacheManager ?? CacheManager() {
    // Automatically wire TokenVault with ApiClient
    ApiClient().configureAuth(
      tokenProvider: () => _tokenVault.getAccessToken(),
      onUnauthorized: () => signOut(),
    );
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        await _tokenVault.clear();
        await _cacheManager.clearPrefix('cached_');
        return null;
      }

      // Sync active token to TokenVault
      final token = await fbUser.getIdToken();
      if (token != null) {
        await _tokenVault.saveAccessToken(token);
      }

      final profile = await getUserProfile(fbUser.uid);
      if (profile != null) return profile;

      // Fallback user model without hardcoded email
      return User(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? 'مستخدم',
        photoURL: fbUser.photoURL,
        role: 'client',
        createdAt: DateTime.now(),
      );
    });
  }

  @override
  User? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return User(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName ?? 'مستخدم',
      photoURL: fbUser.photoURL,
      role: 'client',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser == null) return null;

      // Securely store hardware-encrypted token
      final token = await fbUser.getIdToken();
      if (token != null) {
        await _tokenVault.saveSession(
          accessToken: token,
          userId: fbUser.uid,
        );
      }

      var user = await getUserProfile(fbUser.uid);
      if (user == null) {
        // Create user document if first time
        user = User(
          id: fbUser.uid,
          email: fbUser.email ?? email,
          displayName: fbUser.displayName ?? 'مستخدم',
          photoURL: fbUser.photoURL,
          role: 'client', // Dynamic default role
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.id).set(user.toJson());
      }

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('فشل تسجيل الدخول: ${e.toString()}', originalError: e);
    }
  }

  @override
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String role = 'client',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser == null) return null;

      await fbUser.updateDisplayName(displayName);

      final user = User(
        id: fbUser.uid,
        email: email.trim(),
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
      );

      // Save user profile to Firestore
      await _firestore.collection('users').doc(user.id).set(user.toJson());

      // Save token securely
      final token = await fbUser.getIdToken();
      if (token != null) {
        await _tokenVault.saveSession(
          accessToken: token,
          userId: user.id,
          role: role,
        );
      }

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('فشل إنشاء الحساب: ${e.toString()}', originalError: e);
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Cancelled

      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;
      if (fbUser == null) return null;

      // Secure token save
      final token = await fbUser.getIdToken();
      if (token != null) {
        await _tokenVault.saveSession(
          accessToken: token,
          userId: fbUser.uid,
        );
      }

      var user = await getUserProfile(fbUser.uid);
      if (user == null) {
        user = User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? 'مستخدم',
          photoURL: fbUser.photoURL,
          role: 'client', // Dynamic default
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.id).set(user.toJson());
      }

      return user;
    } catch (e) {
      AppLogger.error('Google Sign-In failed', error: e);
      throw AuthException('فشل تسجيل الدخول عبر Google: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await _tokenVault.clear();
      await _cacheManager.clearPrefix('cached_');
      AppLogger.info('Signed out and cleared all secure credentials and local cache.');
    } catch (e) {
      AppLogger.error('Error during signOut', error: e);
    }
  }

  @override
  Future<String?> getAuthToken({bool forceRefresh = false}) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      final token = await fbUser.getIdToken(forceRefresh);
      if (token != null) {
        await _tokenVault.saveAccessToken(token);
        return token;
      }
    }
    return await _tokenVault.getAccessToken();
  }

  @override
  Future<User?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get user profile', error: e);
      return null;
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? photoURL,
  }) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) throw AuthException('المستخدم غير مسجل الدخول');

    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName;
      await fbUser.updateDisplayName(displayName);
    }
    if (photoURL != null) {
      updates['photoURL'] = photoURL;
      await fbUser.updatePhotoURL(photoURL);
    }
    if (phone != null) {
      updates['phone'] = phone;
    }

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(fbUser.uid).update(updates);
    }
  }

  AuthException _mapFirebaseAuthException(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserNotFoundException();
      case 'wrong-password':
      case 'invalid-credential':
        return InvalidCredentialsException();
      case 'user-disabled':
        return UserDisabledException();
      case 'email-already-in-use':
        return EmailAlreadyInUseException();
      case 'weak-password':
        return WeakPasswordException();
      case 'invalid-email':
        return AuthException('البريد الإلكتروني غير صحيح', code: e.code);
      default:
        return AuthException(e.message ?? 'حدث خطأ في المصادقة', code: e.code, originalError: e);
    }
  }
}
