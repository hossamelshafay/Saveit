import 'package:injectable/injectable.dart';
import 'package:saveit/core/errors/error_handler.dart';
import 'package:saveit/core/errors/exceptions.dart';
// Refactored lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class FirebaseAuthSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //  Register with email & password + save user document
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty ||
          password.trim().isEmpty ||
          username.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-argument',
          message: 'All fields are required',
        );
      }

      if (password.length < 6) {
        throw FirebaseAuthException(code: 'weak-password');
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        await _createUserDocument(result.user!, username.trim());

        // Send email verification
        await result.user!.sendEmailVerification();
      }

      return result;
    } on FirebaseAuthException catch (error) {
      throw ServiceException(ErrorHandler.authMessage(error.code), error.code);
    }
  }

  //  Sign in with email & password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-argument',
          message: 'Email and password are required',
        );
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Check if email is verified
      if (result.user != null && !result.user!.emailVerified) {
        await _auth.signOut();
        throw const ServiceException(
          "Please verify your email before signing in",
          "email-not-verified",
        );
      }

      return result;
    } on FirebaseAuthException catch (error) {
      throw ServiceException(ErrorHandler.authMessage(error.code), error.code);
    }
  }

  //  Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );

      // Sign out first to ensure clean state
      await googleSignIn.signOut();

      // Start sign in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      try {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          await _createUserDocument(
            user,
            user.displayName ?? user.email?.split('@')[0] ?? "User",
          );
        }
        return user;
      } catch (e) {
        // Clean up on error
        await googleSignIn.signOut();
        rethrow;
      }
    } catch (_) {
      rethrow;
    }
  }

  //  Sign in with Facebook
  Future<User?> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final facebookAuthCredential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        final userCredential = await _auth.signInWithCredential(
          facebookAuthCredential,
        );
        final user = userCredential.user;

        if (user != null) {
          await _createUserDocument(user, user.displayName ?? "No Name");
        }
        return user;
      }
      return null;
    } catch (_) {
      rethrow;
    }
  }

  //  Sign in Anonymously
  Future<User?> signInAnonymously({String username = "Anonymous"}) async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        await _createUserDocument(user, username); //  ياخد اللي المستخدم حطه
      }
      return user;
    } catch (_) {
      rethrow;
    }
  }

  //  Sign out (Email / Google / Facebook)
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Handle third-party sign-outs first
      final providers = user.providerData.map((e) => e.providerId).toList();

      if (providers.contains('google.com')) {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      }

      if (providers.contains('facebook.com')) {
        final accessToken = await FacebookAuth.instance.accessToken;
        if (accessToken != null) {
          await FacebookAuth.instance.logOut();
        }
      }

      // Clean up anonymous user data
      if (user.isAnonymous) {
        try {
          await _firestore.collection('users').doc(user.uid).delete();
        } catch (e) {
          debugPrint('Anonymous data cleanup error: $e');
        }
      }

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Firebase sign out
      await _auth.signOut();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  //  Create user document in Firestore (shared function)
  Future<void> _createUserDocument(User user, String username) async {
    // First check if the user document already exists
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      // Only create if it doesn't exist
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? "Anonymous",
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'currency': 'SAR', // Default currency
        'balance': 0.0,
        'income': 0.0,
        'expenses': 0.0,
        'savings': 0.0,
        'totalInstallments': 0.0,
        'paidInstallments': 0.0,
        'photoUrl': user.photoURL,
      }, SetOptions(merge: true));
    }
  }
}
