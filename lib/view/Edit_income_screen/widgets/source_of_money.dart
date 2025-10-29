import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class SourceOfMoney extends StatelessWidget {
  final TextEditingController controller;

  const SourceOfMoney({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Source_of_income'.tr,
        hintText: 'e.g. Salary',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        prefixIcon: const Icon(Icons.attach_money),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a source of income'.tr;
        }
        return null;
      },
    );
  }
}
