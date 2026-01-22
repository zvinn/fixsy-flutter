import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user stream
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        final userData = await getUserData(firebaseUser.uid);
        if (userData != null) return userData;
      } catch (e) {
        // Ignore error and fall back to firebase data
      }

      // Fallback: Create user from Firebase User if Firestore fails
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'مستخدم',
        photoURL: firebaseUser.photoURL,
        role: firebaseUser.email == 'mhamed.saad.ibrahim@gmail.com' ? 'admin' : 'customer',
        createdAt: DateTime.now(),
      );
    });
  }

  // Get current user
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        try {
          // Try to get user data from Firestore
          var user = await getUserData(credential.user!.uid);
          
          // If user doesn't exist in Firestore, create it
          if (user == null) {
            user = User(
              id: credential.user!.uid,
              email: credential.user!.email!,
              displayName: credential.user!.displayName ?? 'مستخدم',
              photoURL: credential.user!.photoURL,
              role: credential.user!.email == 'mhamed.saad.ibrahim@gmail.com' ? 'admin' : 'customer',
              createdAt: DateTime.now(),
            );
            
            await _firestore.collection('users').doc(user.id).set(user.toJson());
          }
          return user;
        } catch (e) {
          // Fallback: If Firestore fails, return basic user
          return User(
            id: credential.user!.uid,
            email: credential.user!.email!,
            displayName: credential.user!.displayName ?? 'مستخدم',
            photoURL: credential.user!.photoURL,
            role: 'customer',
            createdAt: DateTime.now(),
          );
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String role = 'client',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = User(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          role: role,
          createdAt: DateTime.now(),
        );

        try {
          // Save user data to Firestore
          await _firestore.collection('users').doc(user.id).set(user.toJson());
        } catch (e) {
          // Ignore Firestore error
        }
        
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled
        return null;
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        try {
          // Check if user already exists in Firestore
          final existingUser = await getUserData(userCredential.user!.uid);
          
          if (existingUser != null) {
            return existingUser;
          }

          // Create new user document
          final newUser = User(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            displayName: userCredential.user!.displayName ?? 'مستخدم',
            photoURL: userCredential.user!.photoURL,
            role: userCredential.user!.email == 'mhamed.saad.ibrahim@gmail.com' ? 'admin' : 'customer',
            createdAt: DateTime.now(),
          );

          await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
          return newUser;
        } catch (e) {
          // Fallback
          return User(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            displayName: userCredential.user!.displayName ?? 'مستخدم',
            photoURL: userCredential.user!.photoURL,
            role: userCredential.user!.email == 'mhamed.saad.ibrahim@gmail.com' ? 'admin' : 'customer',
            createdAt: DateTime.now(),
          );
        }
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<User?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final userData = doc.data()!;
        // Enforce admin role for specific email even if Firestore has old data
        if (userData['email'] == 'mhamed.saad.ibrahim@gmail.com') {
          userData['role'] = 'admin';
        }
        return User.fromJson({...userData, 'id': doc.id});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
