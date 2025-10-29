import 'package:flutter/material.dart';

/// Maps string names to constant IconData
class AppIcons {
  static const Map<String, IconData> iconMap = {
    'payment': Icons.payment,
    'money': Icons.attach_money,
    'shopping': Icons.shopping_cart,
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'health': Icons.local_hospital,
    'education': Icons.school,
    'entertainment': Icons.movie,
    'bills': Icons.receipt,
    'other': Icons.more_horiz,
  };

  /// Get icon data from string name
  static IconData getIconFromName(String? name) {
    return iconMap[name] ?? Icons.payment;
  }

  /// Get icon name from IconData
  static String? getNameFromIcon(IconData icon) {
    return iconMap.entries
        .firstWhere(
          (entry) => entry.value == icon,
          orElse: () => const MapEntry('payment', Icons.payment),
        )
        .key;
  }
}
