// Refactored lib/model/installment_model.dart
import 'package:material_ui/material_ui.dart';

class InstallmentModel {
  final String? id;
  final String installmentName;
  final double totalAmount;
  final DateTime dueDate;
  final String category;
  final String notes;
  final String currency;
  final bool isPaid;
  final DateTime? paidDate;
  final DateTime createdAt;
  final IconData? icon;
  final Color? iconColor;
  final String timeStatus;

  InstallmentModel({
    dynamic id,
    required this.installmentName,
    required this.totalAmount,
    required this.dueDate,
    required this.category,
    required this.notes,
    required this.currency,
    bool? isPaid,
    this.paidDate,
    required this.createdAt,
    this.icon,
    this.iconColor,
    String? timeStatus,
  }) : id = id?.toString(),
       isPaid = isPaid ?? false,
       timeStatus = timeStatus ?? '';

  // Copy with method for updates
  InstallmentModel copyWith({
    String? id,
    String? installmentName,
    double? totalAmount,
    DateTime? dueDate,
    String? category,
    String? notes,
    String? currency,
    bool? isPaid,
    DateTime? paidDate,
    DateTime? createdAt,
    IconData? icon,
    Color? iconColor,
    String? timeStatus,
  }) {
    return InstallmentModel(
      id: id ?? this.id,
      installmentName: installmentName ?? this.installmentName,
      totalAmount: totalAmount ?? this.totalAmount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      currency: currency ?? this.currency,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      timeStatus: timeStatus ?? this.timeStatus,
    );
  }
}

String installmentDueStatus(DateTime dueDate, DateTime now) {
  final difference = dueDate.difference(now).inDays;

  if (difference == 0) {
    return 'Due Today';
  } else if (difference == 1) {
    return 'Due Tomorrow';
  } else if (difference < 0) {
    return 'Overdue';
  } else {
    return 'In $difference days';
  }
}
