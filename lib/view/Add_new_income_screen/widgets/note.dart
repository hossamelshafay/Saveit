import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';

class Note extends StatelessWidget {
  final void Function(String?) onsaved;
  final String? initialValue;

  const Note({super.key, required this.onsaved, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: 'Note'.tr,
        hintText: 'Optional',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      maxLines: 2,
      onSaved: onsaved,
    );
  }
}
