import 'package:flutter/material.dart';

class Expense {
  final IconData icon;
  final String title;
  final String category;
  final double amount;
  final String date;
  final Color color;

  Expense({
    required this.icon,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.color,
  });
}
