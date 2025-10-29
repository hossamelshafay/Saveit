import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/services/income_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AddNewIncomeScreen extends StatefulWidget {
  final String? incomeId;
  final Map<String, dynamic>? incomeData;

  const AddNewIncomeScreen({super.key, this.incomeId, this.incomeData});

  @override
  State<AddNewIncomeScreen> createState() => _AddNewIncomeScreenState();
}

class _AddNewIncomeScreenState extends State<AddNewIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _audioPlayer = AudioPlayer();
  bool _isSaving = false;

  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = "SAR";
  final List<String> _currencies = ["SAR", "EUR", "USD"];

  @override
  void initState() {
    super.initState();
    if (widget.incomeData != null) {
      _sourceController.text = widget.incomeData!["title"] ?? "";
      _amountController.text = (widget.incomeData!["amount"] ?? 0.0).toString();
      _notesController.text = widget.incomeData!["notes"] ?? "";
      _selectedCurrency = widget.incomeData!["currency"] ?? "SAR";
      if (widget.incomeData!["date"] != null) {
        try {
          _selectedDate = (widget.incomeData!["date"] as Timestamp).toDate();
        } catch (e) {
          _selectedDate = DateTime.now();
        }
      }
    }
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  Future<void> _playSound() async {
    try {
      final completer = Completer<void>();

      // Listen for completion
      final subscription = _audioPlayer.onPlayerComplete.listen((_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      // Play the sound
      await _audioPlayer.play(AssetSource("sounds/money-income.mp3"));

      // Wait for completion or timeout after 1 second
      await Future.any([
        completer.future,
        Future.delayed(const Duration(seconds: 1)),
      ]);

      // Clean up
      subscription.cancel();
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final incomeService = IncomeService();

      // Save income first
      if (widget.incomeId != null) {
        await incomeService.updateIncome(
          incomeId: widget.incomeId!,
          title: _sourceController.text,
          amount: double.parse(_amountController.text),
          notes: _notesController.text,
          date: _selectedDate,
          currency: _selectedCurrency,
          category: "",
        );
      } else {
        await incomeService.addIncome(
          title: _sourceController.text,
          amount: double.parse(_amountController.text),
          category: "",
          currency: _selectedCurrency,
          date: _selectedDate,
          notes: _notesController.text,
        );
      }

      // Play sound after successful save
      await _playSound();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.incomeId != null
                  ? "Income updated successfully"
                  : "Income added successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.incomeId != null ? "Edit Income" : "Add New Income"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Source of Income",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sourceController,
                  decoration: InputDecoration(
                    hintText: "e.g. Salary",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? "Please enter source" : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Amount",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        underline: const SizedBox(),
                        items: _currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCurrency = newValue;
                            });
                          }
                        },
                        style: TextStyle(color: Colors.grey[600]),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey[600],
                        ),
                        elevation: 1,
                        isDense: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: "0.00",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          style: TextStyle(color: Colors.grey[600]),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return "Please enter amount";
                            }
                            if (double.tryParse(value!) == null) {
                              return "Please enter a valid number";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Date of Income",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MM/dd/yyyy').format(_selectedDate),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Icon(Icons.calendar_today, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Notes (Optional)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Notes (Optional)",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveIncome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.incomeId != null
                                ? "Update Income"
                                : "Add New Income",
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
      ),
    );
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
