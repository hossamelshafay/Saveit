import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';

class LogoutController extends GetxController {
  final _authService = AuthService();
  final isLoading = false.obs;

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Show loading overlay
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _authService.signOut();

      // Clear navigation stack and go to login
      await Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      // Close loading dialog if it's open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }
}
