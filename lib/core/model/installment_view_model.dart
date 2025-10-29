// Refactored lib/model/installment_view_model.dart
import 'package:flutter/material.dart';

class InstallmentViewModel {
  final String? id;
  final String title;
  final DateTime dueDate;
  final double amount;
  final bool isPaid;
  final IconData icon;
  final Color iconColor;
  final String timeStatus;
  final String category;
  final String notes;
  final DateTime createdAt;

  InstallmentViewModel({
    this.id,
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.isPaid,
    required this.icon,
    required this.iconColor,
    required this.timeStatus,
    this.category = '',
    this.notes = '',
    required this.createdAt,
  });

  String get status => isPaid ? 'paid' : 'upcoming';

  InstallmentViewModel copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    double? amount,
    bool? isPaid,
    IconData? icon,
    Color? iconColor,
    String? timeStatus,
    String? category,
    String? notes,
    DateTime? createdAt,
  }) {
    return InstallmentViewModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      timeStatus: timeStatus ?? this.timeStatus,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
