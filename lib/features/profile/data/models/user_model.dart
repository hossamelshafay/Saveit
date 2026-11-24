import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saveit/features/profile/domain/entities/user_profile.dart';

// Create from Firestore document
UserProfile decodeUserProfile(Map<String, dynamic> map) {
  return UserProfile(
    uid: map['uid'] ?? '',
    email: map['email'] ?? '',
    username: map['username'] ?? '',
    currency: map['currency'] ?? 'SAR',
    balance: (map['balance'] ?? 0.0).toDouble(),
    income: (map['income'] ?? 0.0).toDouble(),
    expenses: (map['expenses'] ?? 0.0).toDouble(),
    savings: (map['savings'] ?? 0.0).toDouble(),
    totalInstallments: (map['totalInstallments'] ?? 0.0).toDouble(),
    paidInstallments: (map['paidInstallments'] ?? 0.0).toDouble(),
    createdAt: map['createdAt'] != null
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: map['updatedAt'] != null
        ? (map['updatedAt'] as Timestamp).toDate()
        : null,
    photoUrl: map['photoUrl'] as String?,
  );
}
