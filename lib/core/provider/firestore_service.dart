// Refactored lib/core/provider/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/installment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user id
  String? get _userId => _auth.currentUser?.uid;

  /// Add installment
  Future<bool> addInstallment(InstallmentModel installment) async {
    try {
      if (_userId == null) return false;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('installments')
          .add(installment.toMap());

      await updateUserFinancials();
      return true;
    } catch (e) {
      print('Add installment error: $e');
      return false;
    }
  }

  /// Get installments stream (real-time updates)
  Stream<List<InstallmentModel>> getInstallmentsStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('installments')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InstallmentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Get user financial data stream (real-time updates)
  Stream<Map<String, dynamic>> getUserFinancialsStream() {
    if (_userId == null) return Stream.value({});

    return _firestore.collection('users').doc(_userId).snapshots().map((
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
    if (_userId == null) return;

    try {
      // Get all incomes
      QuerySnapshot incomesSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
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
          .doc(_userId)
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
          .doc(_userId)
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
          .doc(_userId)
          .get();

      if (!userDoc.exists || userDoc.data() == null) return;

      Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>? ?? {};
      double savings = (userData['savings'] ?? 0).toDouble();

      // الرصيد يتأثر بالمدفوع فقط
      double balance = totalIncome - totalExpenses - paidInstallments + savings;

      // Update user document
      await _firestore.collection('users').doc(_userId).update({
        'balance': balance,
        'income': totalIncome,
        'expenses': totalExpenses,
        'totalInstallments': totalInstallments, // كل الأقساط
        'paidInstallments': paidInstallments, // المدفوع فقط
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update financials error: $e');
    }
  }

  /// Update user income
  Future<void> updateUserIncome(double income) async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).set({
        'income': income,
      }, SetOptions(merge: true));
      await updateUserFinancials();
    } catch (e) {
      print('Update income error: $e');
    }
  }

  /// Update user expenses
  Future<void> updateUserExpenses(double expenses) async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).set({
        'expenses': expenses,
      }, SetOptions(merge: true));
      await updateUserFinancials();
    } catch (e) {
      print('Update expenses error: $e');
    }
  }

  /// Update user savings
  Future<void> updateUserSavings(double savings) async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).set({
        'savings': savings,
      }, SetOptions(merge: true));
      await updateUserFinancials();
    } catch (e) {
      print('Update savings error: $e');
    }
  }

  /// Delete installment
  Future<bool> deleteInstallment(String installmentId) async {
    try {
      if (_userId == null) return false;

      final docRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('installments')
          .doc(installmentId);

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final isPaid = data['isPaid'] ?? false;
        final rawAmount = data['totalAmount'] ?? 0;
        final amount = (rawAmount is int)
            ? rawAmount.toDouble()
            : (rawAmount is double ? rawAmount : 0.0);

        // لو القسط مدفوع، نرجعه للرصيد
        if (isPaid) {
          final userDoc = await _firestore
              .collection('users')
              .doc(_userId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            double currentBalance = (userData['balance'] ?? 0).toDouble();

            await _firestore.collection('users').doc(_userId).update({
              'balance': currentBalance + amount,
            });
          }
        }
      }

      await docRef.delete();
      await updateUserFinancials();
      return true;
    } catch (e) {
      print('Delete installment error: $e');
      return false;
    }
  }

  /// Mark installment as paid
  Future<bool> markInstallmentAsPaid(String installmentId) async {
    try {
      if (_userId == null) return false;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('installments')
          .doc(installmentId)
          .update({'isPaid': true, 'paidDate': FieldValue.serverTimestamp()});

      await updateUserFinancials();
      return true;
    } catch (e) {
      print('Mark paid error: $e');
      return false;
    }
  }
}
