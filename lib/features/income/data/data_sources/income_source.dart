import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@lazySingleton
class IncomeSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID - returns null if not authenticated
  String? get _userId => _auth.currentUser?.uid;

  /// Add income to user-specific subcollection
  Future<void> addIncome({
    required String title,
    required double amount,
    required String category,
    required String currency,
    required DateTime date,
    String? notes,
  }) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('incomes')
          .add({
            'title': title,
            'amount': amount,
            'category': category,
            'currency': currency,
            'notes': notes ?? '',
            'date': Timestamp.fromDate(date),
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Update user's total income and balance
    } catch (e) {
      debugPrint("Error adding income: $e");
      rethrow;
    }
  }

  /// Get user-specific incomes stream
  Stream<List<Map<String, dynamic>>> getUserIncomesStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('incomes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final date = data['date'];
            return {
              'id': doc.id,
              ...data,
              if (date is Timestamp) 'date': date.toDate(),
            };
          }).toList(),
        );
  }

  /// Delete income
  Future<bool> deleteIncome(String incomeId) async {
    try {
      if (_userId == null) return false;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('incomes')
          .doc(incomeId)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Delete income error: $e');
      return false;
    }
  }

  /// Update income
  Future<bool> updateIncome({
    required String incomeId,
    required String title,
    required double amount,
    required String category,
    required String currency,
    required DateTime date,
    String? notes,
  }) async {
    try {
      if (_userId == null) return false;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('incomes')
          .doc(incomeId)
          .update({
            'title': title,
            'amount': amount,
            'category': category,
            'currency': currency,
            'date': Timestamp.fromDate(date),
            'notes': notes ?? '',
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      debugPrint('Update income error: $e');
      return false;
    }
  }
}
