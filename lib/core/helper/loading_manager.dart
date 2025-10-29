import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingManager {
  static bool _isLoading = false;
  static OverlayEntry? _overlayEntry;

  /// Show loading overlay
  static void showLoading({String message = 'Loading...'}) {
    if (_isLoading) return;

    _isLoading = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(Get.context!).insert(_overlayEntry!);
  }

  /// Hide loading overlay
  static void hideLoading() {
    if (!_isLoading) return;

    _isLoading = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Show loading with automatic timeout
  static void showLoadingWithTimeout({
    String message = 'Loading...',
    Duration timeout = const Duration(seconds: 30),
  }) {
    showLoading(message: message);

    Future.delayed(timeout, () {
      if (_isLoading) {
        hideLoading();
        Get.snackbar(
          'Timeout',
          'Operation timed out. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    });
  }

  /// Execute function with loading
  static Future<T?> executeWithLoading<T>(
    Future<T> Function() function, {
    String message = 'Loading...',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    showLoadingWithTimeout(message: message, timeout: timeout);

    try {
      final result = await function();
      hideLoading();
      return result;
    } catch (e) {
      hideLoading();
      rethrow;
    }
  }
}
