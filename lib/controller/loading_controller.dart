import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingController extends GetxController {
  final isLoading = false.obs;

  void showLoading() {
    if (!isLoading.value) {
      isLoading.value = true;
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: const Center(child: CircularProgressIndicator()),
        ),
        barrierDismissible: false,
      );
    }
  }

  void hideLoading() {
    if (isLoading.value) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      isLoading.value = false;
    }
  }
}
