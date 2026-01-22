import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../data/models/user.dart';
import '../../data/services/auth_service.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/app_error_handler.dart';
import '../../core/utils/app_logger.dart';
import '../../data/services/analytics_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      AppLogger.info('Sign in attempt');
      final user = await _authService.signInWithEmailAndPassword(email, password);
      _currentUser = user;
      AppLogger.info('Sign in successful', data: {'userId': user?.id});
      
      if (user != null) {
        await AnalyticsService.logLogin(method: 'email');
      }
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase auth error', error: e);
      throw AppErrorHandler.handleAuthError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Sign in error', error: e, stackTrace: stackTrace);
      throw AppErrorHandler.handleApiError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String role = 'client',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      AppLogger.info('Sign up attempt');
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      _currentUser = user;
      AppLogger.info('Sign up successful', data: {'userId': user?.id});
      
      if (user != null) {
        await AnalyticsService.logSignUp(method: 'email');
      }
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase registration error', error: e);
      throw AppErrorHandler.handleAuthError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Sign up error', error: e, stackTrace: stackTrace);
      throw AppErrorHandler.handleApiError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      AppLogger.info('Google sign in attempt');
      final user = await _authService.signInWithGoogle();
      _currentUser = user;
      AppLogger.info('Google sign in successful', data: {'userId': user?.id});
      
      if (user != null) {
        await AnalyticsService.logLogin(method: 'google');
      }
    } on FirebaseException catch (e) {
      AppLogger.error('Google sign in error', error: e);
      throw AppErrorHandler.handleAuthError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Google sign in unexpected error', error: e, stackTrace: stackTrace);
      throw UnknownException('حدث خطأ في تسجيل الدخول بواسطة Google');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.info('Sign out attempt');
      await _authService.signOut();
      _currentUser = null;
      AppLogger.info('Sign out successful');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Sign out error', error: e, stackTrace: stackTrace);
      throw UnknownException('حدث خطأ في تسجيل الخروج');
    }
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}
