// Refactored lib/view/Add_new_income_screen/widgets/source_of_money.dart
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class Sourceofmoney extends StatelessWidget {
  final void Function(String?) onsaved;
  final String? initialValue;

  const Sourceofmoney({super.key, required this.onsaved, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: 'Source_of_income'.tr,
        hintText: 'e.g. Salary',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onSaved: onsaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a source of income'.tr;
        }
        return null;
      },
    );
  }
}
