import 'package:firebase_auth/firebase_auth.dart';

import 'failures.dart';
import 'exceptions.dart';

abstract final class ErrorHandler {
  static Failure from(Object error) => switch (error) {
    ServiceException(:final message, :final code) => Failure(
      message,
      code: code,
    ),
    FirebaseAuthException(:final message, :final code) => Failure(
      message ?? 'Something went wrong',
      code: code,
    ),
    _ => Failure(error.toString()),
  };

  static String authMessage(String code) => switch (code) {
    'user-not-found' => 'No user found with this email address.',
    'wrong-password' => 'Incorrect password. Please try again.',
    'email-already-in-use' =>
      'An account already exists with this email address.',
    'weak-password' =>
      'Password is too weak. Please choose a stronger password.',
    'invalid-email' => 'Invalid email address format.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' => 'Too many failed attempts. Please try again later.',
    'network-request-failed' =>
      'Network error. Please check your internet connection.',
    _ => 'An error occurred. Please try again.',
  };
}
