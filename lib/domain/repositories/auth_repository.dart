import '../../data/models/user.dart';

/// Clean Auth Repository Contract (Interface)
/// Enforces Fixsy Constitution Principle I (Strict Clean Architecture).
abstract class IAuthRepository {
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Currently logged in user (if any)
  User? get currentUser;

  /// Sign in using email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register a new user account
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String role = 'client',
  });

  /// Sign in with Google provider
  Future<User?> signInWithGoogle();

  /// Sign out and wipe credentials from TokenVault
  Future<void> signOut();

  /// Retrieve the active JWT authentication token
  Future<String?> getAuthToken({bool forceRefresh = false});

  /// Fetch user profile details by ID
  Future<User?> getUserProfile(String userId);

  /// Update user profile information
  Future<void> updateProfile({
    String? displayName,
    String? phone,
    String? photoURL,
  });
}
