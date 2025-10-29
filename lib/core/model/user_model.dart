import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String currency;
  final double balance;
  final double income;
  final double expenses;
  final double savings;
  final double totalInstallments;
  final double paidInstallments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.currency,
    required this.balance,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.createdAt,
    this.updatedAt,
    this.photoUrl,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'currency': currency,
      'balance': balance,
      'income': income,
      'expenses': expenses,
      'savings': savings,
      'totalInstallments': totalInstallments,
      'paidInstallments': paidInstallments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'photoUrl': photoUrl,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
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

  // Copy with method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? currency,
    double? balance,
    double? income,
    double? expenses,
    double? savings,
    double? totalInstallments,
    double? paidInstallments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      income: income ?? this.income,
      expenses: expenses ?? this.expenses,
      savings: savings ?? this.savings,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, username: $username, currency: $currency, balance: $balance, income: $income, expenses: $expenses, savings: $savings, totalInstallments: $totalInstallments)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.username == username &&
        other.currency == currency &&
        other.balance == balance &&
        other.income == income &&
        other.expenses == expenses &&
        other.savings == savings &&
        other.totalInstallments == totalInstallments;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        username.hashCode ^
        currency.hashCode ^
        balance.hashCode ^
        income.hashCode ^
        expenses.hashCode ^
        savings.hashCode ^
        totalInstallments.hashCode;
  }
}
