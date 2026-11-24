import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saveit/features/expenses/domain/entities/expense.dart';

@lazySingleton
class ExpenseSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID - returns null if not authenticated
  String? get _userId => _auth.currentUser?.uid;

  /// Add expense to user-specific subcollection
  Future<void> addExpenseToFirebase(Expense expense, {String? notes}) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Parse the date string into a DateTime object
      DateTime expenseDate;
      final dateParts = expense.date.split('/');
      if (dateParts.length == 3) {
        expenseDate = DateTime(
          int.parse(dateParts[2]), // year
          int.parse(dateParts[0]), // month
          int.parse(dateParts[1]), // day
        );
      } else {
        expenseDate = DateTime.now();
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .add({
            'title': expense.title,
            'category': expense.category,
            'amount': expense.amount,
            'date': Timestamp.fromDate(expenseDate),
            'notes': notes ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Update user's total expenses and balance
    } catch (e) {
      debugPrint("Error adding expense: $e");
      rethrow;
    }
  }

  /// Get user-specific expenses stream
  Stream<List<Map<String, dynamic>>> getUserExpensesStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('expenses')
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

  /// Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      if (_userId == null) return false;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .doc(expenseId)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Delete expense error: $e');
      return false;
    }
  }

  /// Update expense
  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required String currency,
    required String date,
    String? note,
  }) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Parse the date string into a DateTime object
      DateTime expenseDate;
      final dateParts = date.split('/');
      if (dateParts.length == 3) {
        expenseDate = DateTime(
          int.parse(dateParts[2]), // year
          int.parse(dateParts[0]), // month
          int.parse(dateParts[1]), // day
        );
      } else {
        expenseDate = DateTime.now();
      }

      final Map<String, dynamic> updateData = {
        'title': title,
        'amount': amount,
        'category': category,
        'currency': currency,
        'date': Timestamp.fromDate(expenseDate),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (note != null) {
        updateData['note'] = note;
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .doc(id)
          .update(updateData);

      // Update user's total expenses and balance
    } catch (e) {
      debugPrint('Update expense error: $e');
      rethrow;
    }
  }
}
