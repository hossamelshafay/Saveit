import '../core/services/auth_service.dart';
import '../view/Home_screen/Home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../core/provider/user_provider.dart';
import '../core/provider/firestore_service.dart';

class RegisterController extends GetxController {
  final AuthService _authServices = AuthService();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final termsAccepted = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void toggleTerms(bool? value) {
    termsAccepted.value = value ?? false;
  }

  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      setLoading(true);
      final username = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        Get.snackbar(
          "Error",
          "Passwords do not match",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (!termsAccepted.value) {
        Get.snackbar(
          "Error",
          "Please accept the terms and conditions",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      UserCredential? userCredential = await _authServices
          .registerWithEmailAndPassword(email, password, username);

      if (userCredential != null && userCredential.user != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData(forceRefresh: true);
        await FirestoreService().updateUserFinancials();
        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar(
          "Error",
          "Failed to register",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setLoading(false);
    }
  }

  Future<void> registerWithGoogle(BuildContext context) async {
    try {
      setLoading(true);
      final user = await _authServices.signInWithGoogle();

      if (user != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData(forceRefresh: true);
        await FirestoreService().updateUserFinancials();
        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar(
          "Error",
          "Google sign-in failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setLoading(false);
    }
  }

  Future<void> registerAnonymously(BuildContext context) async {
    try {
      setLoading(true);
      final user = await _authServices.signInAnonymously();

      if (user != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData(forceRefresh: true);
        await FirestoreService().updateUserFinancials();
        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar(
          "Error",
          "Anonymous sign-in failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
