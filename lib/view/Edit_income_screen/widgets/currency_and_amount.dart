import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class CurrencyAndAmount extends StatelessWidget {
  final TextEditingController amountController;
  final String currency;
  final ValueChanged<String?> onCurrencyChanged;

  const CurrencyAndAmount({
    super.key,
    required this.amountController,
    required this.currency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                return 'Please enter an amount'.tr;
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number'.tr;
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: currency,
            underline: const SizedBox(),
            items: ['USD', 'EUR', 'SAR', 'EGP'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: onCurrencyChanged,
          ),
        ),
      ],
    );
  }
}
