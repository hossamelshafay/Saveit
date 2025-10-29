import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class Addincomebutton extends StatelessWidget {
  final VoidCallback onpressed;
  final bool isEditMode;

  const Addincomebutton({
    super.key,
    required this.onpressed,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onpressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isEditMode ? 'Update the income'.tr : 'Add the income'.tr,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
