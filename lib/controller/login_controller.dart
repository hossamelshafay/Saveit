import '../core/services/auth_service.dart';
import '../view/Home_screen/Home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../core/provider/user_provider.dart';
import '../core/provider/firestore_service.dart';

class LoginController extends GetxController {
  final AuthService _authServices = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = true.obs;
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setLoading(bool value) {
    isLoading.value = value;
  }

  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      setLoading(true);
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Clear any existing user data first
      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clearUserData();
      }

      // Attempt to sign in
      UserCredential? userCredential = await _authServices
          .signInWithEmailAndPassword(email, password);

      if (userCredential?.user == null) {
        throw Exception("Email or Password incorrect!");
      }

      if (!context.mounted) return;

      // Load user data and ensure it's complete
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData(forceRefresh: true);

      // Double check the data was loaded
      if (userProvider.currentUser == null) {
        throw Exception("Failed to load user data");
      }

      // Update financials and verify
      final firestoreService = FirestoreService();
      await firestoreService.updateUserFinancials();

      // Only navigate if context is still valid
      if (context.mounted) {
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close any open loading dialogs
      }
      setLoading(false);
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      setLoading(true);

      // Get mounted context
      if (!context.mounted) return;

      final user = await _authServices.signInWithGoogle();

      if (user == null) {
        throw Exception("Google sign-in failed");
      }

      // Check if context is still mounted before proceeding
      if (!context.mounted) return;

      // Load user data using the correct context and force refresh for Google sign-in
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData(forceRefresh: true);

      // Update financials before navigation
      await FirestoreService().updateUserFinancials();

      // Check context again before navigation
      if (!context.mounted) return;

      // Only navigate if user data was loaded successfully
      await Get.offAll(() => const HomeScreen());
    } catch (e) {
      // Only show error if context is still mounted
      if (context.mounted) {
        Get.snackbar(
          "Error",
          "Google sign-in failed: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (context.mounted) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loginAnonymously(BuildContext context) async {
    try {
      setLoading(true);
      final user = await _authServices.signInAnonymously();

      if (user == null) {
        throw Exception("Anonymous sign-in failed");
      }

      // Load user data using the correct context and force refresh for anonymous login
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData(forceRefresh: true);

      // Only navigate if user data was loaded successfully
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Anonymous sign-in failed: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
