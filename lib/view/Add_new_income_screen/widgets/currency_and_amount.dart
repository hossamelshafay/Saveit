import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class Currencyandamount extends StatelessWidget {
  final String currency;
  final void Function(String?) currencychange;
  final void Function(String?) currencysaved;
  final void Function(String?) amountsaved;
  final String? initialAmount;

  const Currencyandamount({
    super.key,
    required this.currency,
    required this.currencychange,
    required this.currencysaved,
    required this.amountsaved,
    this.initialAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'currency'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            initialValue: currency,
            items: [
              'SUR',
              'USD',
              'EGP',
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: currencychange,
            onSaved: currencysaved,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: initialAmount,
            decoration: InputDecoration(
              labelText: 'Amount'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onSaved: amountsaved,
          ),
        ),
      ],
    );
  }
}
