import 'package:firebase_auth/firebase_auth.dart';

/// Interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current user
  User? getCurrentUser();

  /// Get the current user's ID
  String? getCurrentUserId();

  /// Check if a user is currently signed in
  bool isUserSignedIn();

  /// Delete the current user's account
  Future<void> deleteAccount();

  /// Update user's display name
  Future<void> updateDisplayName(String displayName);

  /// Update user's email
  Future<void> updateEmail(String newEmail);

  /// Update user's password
  Future<void> updatePassword(String newPassword);

  /// Verify user's email
  Future<void> sendEmailVerification();

  /// Check if user's email is verified
  bool isEmailVerified();
}
