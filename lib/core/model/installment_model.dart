// Refactored lib/model/installment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'installmentName': installmentName,
      'totalAmount': totalAmount,
      'dueDate': Timestamp.fromDate(dueDate),
      'category': category,
      'notes': notes,
      'currency': currency,
      'isPaid': isPaid,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'icon': icon?.codePoint,
      'iconColor': iconColor?.value,
      'timeStatus': timeStatus,
    };
  }

  // Create from Firestore document
  factory InstallmentModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    // Handle the case where old data has a dueDate as a String
    DateTime parsedDueDate;
    if (map['dueDate'] is Timestamp) {
      parsedDueDate = (map['dueDate'] as Timestamp).toDate();
    } else if (map['dueDate'] is String) {
      try {
        parsedDueDate = DateTime.parse(map['dueDate'] as String);
      } catch (e) {
        parsedDueDate = DateTime.now();
      }
    } else {
      parsedDueDate = DateTime.now();
    }

    final createdAt = map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    final totalAmount = map['totalAmount'];
    double parsedAmount;
    if (totalAmount is int) {
      parsedAmount = totalAmount.toDouble();
    } else if (totalAmount is double) {
      parsedAmount = totalAmount;
    } else {
      parsedAmount = 0.0;
    }

    return InstallmentModel(
      id: documentId,
      installmentName: (map['installmentName'] ?? '').toString(),
      totalAmount: parsedAmount,
      dueDate: parsedDueDate,
      category: (map['category'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      currency: (map['currency'] ?? 'SAR').toString(),
      isPaid: map['isPaid'] as bool? ?? false,
      paidDate: map['paidDate'] is Timestamp
          ? (map['paidDate'] as Timestamp).toDate()
          : null,
      createdAt: createdAt,
      icon: map['icon'] != null
          ? IconData(map['icon'] as int, fontFamily: 'MaterialIcons')
          : null,
      iconColor: map['iconColor'] != null
          ? Color(map['iconColor'] as int)
          : null,
      timeStatus: (map['timeStatus'] ?? '').toString(),
    );
  }

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
