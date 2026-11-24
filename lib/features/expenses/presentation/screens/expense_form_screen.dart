import 'package:saveit/app/localization/app_translations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/expenses/presentation/cubit/expense_cubit.dart';

import '../widgets/expense_date_field.dart';
import '../widgets/expense_amount_field.dart';
import '../widgets/expense_category_field.dart';

// Refactored lib/view/Add_new_expenses/Add_new_expenses.dart
import 'package:material_ui/material_ui.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:saveit/features/expenses/presentation/widgets/expense_categories.dart';
import 'package:saveit/features/expenses/domain/entities/expense.dart';

const List<String> currencies = ['SAR', 'EUR', 'EGP'];

class AddExpenseScreen extends StatefulWidget {
  final String? expenseId;
  final Map<String, dynamic>? expenseData;

  const AddExpenseScreen({super.key, this.expenseId, this.expenseData});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String selectedCategory;
  late String selectedCurrency;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final TextEditingController _notesController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  int selectedCategoryIndex = 2;

  bool get isEditMode => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values first to ensure they're never null
    _titleController = TextEditingController();
    _amountController = TextEditingController();

    // Then set their values from widget.expenseData if available
    if (widget.expenseData != null) {
      _titleController.text = widget.expenseData!['title'] ?? '';
      _amountController.text =
          (widget.expenseData!['amount'] as num?)?.toString() ?? '';
      _notesController.text = widget.expenseData!['note'] ?? '';

      // Parse the date from the expense data
      if (widget.expenseData!['date'] != null) {
        if (widget.expenseData!['date'] is DateTime) {
          selectedDate = (widget.expenseData!['date'] as DateTime);
        } else if (widget.expenseData!['date'] is String) {
          final dateParts = widget.expenseData!['date'].split('/');
          if (dateParts.length == 3) {
            selectedDate = DateTime(
              int.parse(dateParts[2]), // year
              int.parse(dateParts[0]), // month
              int.parse(dateParts[1]), // day
            );
          }
        }
      }

      // Find and set the category index
      final category = widget.expenseData!['category'];
      if (category != null) {
        selectedCategoryIndex = dummyCategories.indexWhere(
          (c) => c.label == category,
        );
        if (selectedCategoryIndex == -1) selectedCategoryIndex = 2;
      }
    }

    selectedCategory = dummyCategories[selectedCategoryIndex].label;
    selectedCurrency = widget.expenseData?['currency'] ?? currencies.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    final title = _titleController.text;
    final amountText = _amountController.text;

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final category = dummyCategories[selectedCategoryIndex];
      await context.read<ExpenseCubit>().save(
        id: widget.expenseId,
        expense: Expense(
          icon: category.icon,
          title: title,
          category: category.label,
          amount: amount,
          date:
              "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}",
          color: Colors.red,
        ),
        currency: selectedCurrency,
        notes: _notesController.text,
      );
      await _audioPlayer.play(AssetSource('sounds/money-expense.mp3'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (isEditMode
                      ? 'Expense updated successfully'
                      : 'Expense added successfully')
                  .tr(context),
            ),
            backgroundColor: isEditMode ? Colors.red : Colors.green,
          ),
        );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${isEditMode ? 'update' : 'add'} expense: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Expense' : 'Add Expense',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF757575)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Expense Name
              const Text(
                'Expense Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                decoration: InputDecoration(
                  hintText: 'Enter expense name',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFBDBDBD),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ExpenseAmountField(
                amountController: _amountController,
                currencies: currencies,
                selectedCurrency: selectedCurrency,
                onCurrencyChanged: (value) {
                  if (value != null) setState(() => selectedCurrency = value);
                },
              ),

              ExpenseDateField(selectedDate: selectedDate, onTap: _pickDate),
              ExpenseCategoryField(
                selectedCategoryIndex: selectedCategoryIndex,
                onCategoryChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategoryIndex = value);
                  }
                },
              ),

              // 5. Notes
              const Text(
                'Notes (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
                decoration: InputDecoration(
                  hintText: "Notes (Optional)",
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFBDBDBD),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: _saveExpense,
            child: Text(
              isEditMode ? 'Update Expense' : 'Add Expense',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
