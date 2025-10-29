import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class AddIncomeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddIncomeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      height: 56, // نفس ارتفاع زر Add Installment
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 24, color: Colors.white),
        label: Text(
          "add_income".tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF4CAF50,
          ), // اللون الأخضر الخاص بالـ Income
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // نفس الانحناء
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ), // padding داخلي موحد
        ),
      ),
    );
  }
}
