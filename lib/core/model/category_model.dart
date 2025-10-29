import 'package:flutter/material.dart';

class CategoryModel {
  final IconData icon;
  final String label;

  CategoryModel({required this.icon, required this.label});

  CategoryModel copyWith({IconData? icon, String? label}) {
    return CategoryModel(icon: icon ?? this.icon, label: label ?? this.label);
  }
}
