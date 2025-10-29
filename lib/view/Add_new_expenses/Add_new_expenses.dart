// Refactored lib/view/Add_new_expenses/Add_new_expenses.dart
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/model/category_model.dart';
import '../../core/model/dummy_categories.dart';
import '../../core/model/expenses_model.dart';
import '../../core/services/expense_service.dart';

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
        if (widget.expenseData!['date'] is Timestamp) {
          selectedDate = (widget.expenseData!['date'] as Timestamp).toDate();
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

  void _showAddCategoryDialog() {
    final TextEditingController customCategoryController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Custom Category"),
          content: TextField(
            controller: customCategoryController,
            decoration: const InputDecoration(hintText: "Enter category name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (customCategoryController.text.isNotEmpty) {
                  setState(() {
                    dummyCategories.insert(
                      dummyCategories.length - 1,
                      CategoryModel(
                        label: customCategoryController.text,
                        icon: Icons.category,
                      ),
                    );
                    selectedCategoryIndex = dummyCategories.length - 2;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
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
      if (isEditMode) {
        // Update existing expense
        await ExpenseService().updateExpense(
          id: widget.expenseId!,
          title: title,
          amount: amount,
          category: dummyCategories[selectedCategoryIndex].label,
          currency: selectedCurrency,
          date:
              "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}",
          note: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        await _audioPlayer.play(AssetSource('sounds/money-expense.mp3'));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Expense updated successfully'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Add new expense
        final expense = Expense(
          icon: dummyCategories[selectedCategoryIndex].icon,
          title: title,
          category: dummyCategories[selectedCategoryIndex].label,
          amount: amount,
          date:
              "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}",
          color: Colors.red,
        );

        await ExpenseService().addExpenseToFirebase(
          expense,
          notes: _notesController.text,
        );

        await _audioPlayer.play(AssetSource('sounds/money-expense.mp3'));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Expense added successfully'.tr),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
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

              // 2. Amount
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(currency),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                selectedCurrency = value;
                              });
                            }
                          },
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
                        controller: _amountController,
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

              // 3. Date of Expense
              const Text(
                'Date of Expense',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFEEEEEE)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Color(0xFF757575),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Category
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    items: List.generate(
                      dummyCategories.length,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(
                          dummyCategories[index].label.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategoryIndex = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
