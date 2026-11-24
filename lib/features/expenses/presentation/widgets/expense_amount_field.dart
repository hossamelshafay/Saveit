import 'package:material_ui/material_ui.dart';

class ExpenseAmountField extends StatelessWidget {
  const ExpenseAmountField({
    super.key,
    required this.amountController,
    required this.currencies,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });
  final TextEditingController amountController;
  final List<String> currencies;
  final String selectedCurrency;
  final ValueChanged<String?> onCurrencyChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 75,
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // Currency Dropdown
              Container(
                margin: const EdgeInsets.only(left: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCurrency,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF757575),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF212121),
                      fontWeight: FontWeight.w500,
                    ),
                    items: currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(currency),
                        ),
                      );
                    }).toList(),
                    onChanged: onCurrencyChanged,
                  ),
                ),
              ),
              Container(
                height: 24,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFEEEEEE),
              ),
              // Amount TextField
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
