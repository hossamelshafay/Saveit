import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:saveit/features/balance/domain/entities/balance_totals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@lazySingleton
class FinancialTotalsSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user id
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Get user financial data stream (real-time updates)
  Stream<Map<String, dynamic>> getUserFinancialsStream() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value({});

    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return {};
    });
  }

  /// Update user financial data (balance + installments)
  Future<void> updateUserFinancials() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // Get all incomes
      QuerySnapshot incomesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('incomes')
          .get();

      double totalIncome = 0.0;
      for (var doc in incomesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] ?? 0).toDouble();
        totalIncome += amount;
      }

      // Get all expenses
      QuerySnapshot expensesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .get();

      double totalExpenses = 0.0;
      for (var doc in expensesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['amount'] ?? 0).toDouble();
        totalExpenses += amount;
      }

      // Get all installments
      QuerySnapshot installmentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('installments')
          .get();

      double totalInstallments = 0.0; // مجموع كل الأقساط
      double paidInstallments = 0.0; // مجموع الأقساط المدفوعة بس

      for (var doc in installmentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rawAmount = data['totalAmount'] ?? 0;
        final amount = (rawAmount is int)
            ? rawAmount.toDouble()
            : (rawAmount is double ? rawAmount : 0.0);

        totalInstallments += amount;

        final isPaid = data['isPaid'] ?? false;
        if (isPaid) {
          paidInstallments += amount;
        }
      }

      // Get current user data
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists || userDoc.data() == null) return;

      Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>? ?? {};
      double savings = (userData['savings'] ?? 0).toDouble();

      // الرصيد يتأثر بالمدفوع فقط
      final balance = BalanceTotals(
        income: totalIncome,
        expenses: totalExpenses,
        paidInstallments: paidInstallments,
        savings: savings,
      ).balance;

      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'balance': balance,
        'income': totalIncome,
        'expenses': totalExpenses,
        'totalInstallments': totalInstallments, // كل الأقساط
        'paidInstallments': paidInstallments, // المدفوع فقط
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Update financials error: $e');
    }
  }
}
