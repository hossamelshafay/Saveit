import 'package:saveit/app/localization/app_translations.dart';
import 'package:material_ui/material_ui.dart';

import 'expense_categories.dart';

class ExpenseCategoryField extends StatelessWidget {
  const ExpenseCategoryField({
    super.key,
    required this.selectedCategoryIndex,
    required this.onCategoryChanged,
  });
  final int selectedCategoryIndex;
  final ValueChanged<int?> onCategoryChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedCategoryIndex != 2
                  ? Colors.red
                  : Color(0xFFEEEEEE),
              width: selectedCategoryIndex != 2 ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedCategoryIndex,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: selectedCategoryIndex != 2
                    ? Colors.red
                    : Color(0xFF757575),
              ),
              style: TextStyle(
                fontSize: 16,
                color: selectedCategoryIndex != 2
                    ? Colors.red
                    : Color(0xFF212121),
                fontWeight: FontWeight.w400,
              ),
              hint: const Text(
                'Select or type a category',
                style: TextStyle(fontSize: 16, color: Color(0xFFBDBDBD)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              items: List.generate(
                dummyCategories.length,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(
                    dummyCategories[index].label.tr(context),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              onChanged: onCategoryChanged,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
