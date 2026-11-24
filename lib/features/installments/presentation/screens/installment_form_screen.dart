import 'package:saveit/app/localization/app_translations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/installments/presentation/cubit/installment_cubit.dart';

import '../widgets/installment_notes_field.dart';
import '../widgets/installment_amount_field.dart';
import '../widgets/installment_category_field.dart';

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:saveit/features/installments/domain/entities/installment.dart';

class AddInstallmentScreen extends StatefulWidget {
  final InstallmentModel? installmentToEdit;

  const AddInstallmentScreen({super.key, this.installmentToEdit});

  @override
  State<AddInstallmentScreen> createState() => _AddInstallmentScreenState();
}

class _AddInstallmentScreenState extends State<AddInstallmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCurrency = 'SAR';
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> _currencies = ['SAR', 'USD', 'E.G'];
  final List<String> _categories = [
    'Bills',
    'Shopping',
    'Food',
    'Transport',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.installmentToEdit != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    if (widget.installmentToEdit != null) {
      _titleController.text = widget.installmentToEdit!.installmentName;
      _amountController.text = widget.installmentToEdit!.totalAmount.toString();
      _selectedDate = widget.installmentToEdit!.dueDate;
      _categoryController.text = widget.installmentToEdit!.category;
      _notesController.text = widget.installmentToEdit!.notes;
      _dueDateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dueDateController.text = DateFormat('MM/dd/yyyy').format(date);
      });
    }
  }

  Future<void> _saveInstallment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_due_date'.tr(context))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final installment = InstallmentModel(
        id: widget.installmentToEdit?.id,
        installmentName: _titleController.text.trim(),
        dueDate: _selectedDate!,
        totalAmount: double.parse(_amountController.text),
        category: _categoryController.text.trim(),
        notes: _notesController.text.trim(),
        currency: _selectedCurrency,
        isPaid: widget.installmentToEdit?.isPaid ?? false,
        paidDate: widget.installmentToEdit?.paidDate,
        createdAt: widget.installmentToEdit?.createdAt ?? DateTime.now(),
        icon: Icons.receipt,
        iconColor: Colors.blue,
      );

      await context.read<InstallmentCubit>().save(installment);
      if (mounted) {
        final message = widget.installmentToEdit != null
            ? 'installment_updated'
            : 'installment_added';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message.tr(context))));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.installmentToEdit != null
              ? 'edit_installment'.tr(context)
              : 'add_installment'.tr(context),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                controller: _titleController,
                label: 'installment_name'.tr(context),
                hint: 'enter_installment_name'.tr(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'please_enter_name'.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              InstallmentAmountField(
                amountController: _amountController,
                currencies: _currencies,
                selectedCurrency: _selectedCurrency,
                onCurrencyChanged: (value) {
                  if (value != null) setState(() => _selectedCurrency = value);
                },
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _dueDateController,
                label: 'due_date'.tr(context),
                hint: 'mm/dd/yyyy',
                suffixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'select_due_date'.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              InstallmentCategoryField(
                selectedCategory: _categoryController.text,
                categories: _categories,
                onCategoryChanged: (value) {
                  if (value != null) {
                    setState(() => _categoryController.text = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              InstallmentNotesField(notesController: _notesController),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveInstallment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.installmentToEdit != null
                              ? 'update_installment'.tr(context)
                              : 'add_installment_btn'.tr(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey[400])
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
