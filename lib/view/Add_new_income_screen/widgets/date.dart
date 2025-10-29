import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class Date extends StatelessWidget {
  final String date;
  final VoidCallback ontap;
  const Date({super.key, required this.date, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Date'.tr,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      controller: TextEditingController(text: date),
      onTap: ontap,
    );
  }
}
