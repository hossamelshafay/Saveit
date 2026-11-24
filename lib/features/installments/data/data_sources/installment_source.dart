import 'package:injectable/injectable.dart';
// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/installments/domain/entities/installment.dart';

@lazySingleton
class InstallmentSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Define a constant map of supported icons
  static const Map<int, IconData> _supportedIcons = {
    0xe066: Icons.attach_money, // Default payment icon
    0xe3ab: Icons.payment, // Payment icon
    0xe491: Icons.receipt, // Receipt icon
    0xe745: Icons.delete_outline, // Delete icon
    0xe149: Icons.archive_outlined, // Archive icon
    0xe159: Icons.arrow_back, // Back arrow
    0xe145: Icons.add, // Add icon
    0xe3a3: Icons.alarm, // Alarm icon
  };

  // Safely get IconData from code point
  IconData _getIconData(int? codePoint) {
    if (codePoint == null) return Icons.payment;
    return _supportedIcons[codePoint] ?? Icons.payment;
  }

  // Safely get code point from IconData
  int _getIconCodePoint(IconData? icon) {
    if (icon == null) return Icons.payment.codePoint;
    // Find the code point in our supported icons
    for (var entry in _supportedIcons.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return Icons.payment.codePoint;
  }

  static const String _installmentsCollection = 'installments';

  /// Stream installments for current user
  Stream<List<InstallmentModel>> getInstallmentsStream() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection(_installmentsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return InstallmentModel(
              id: doc.id,
              installmentName: data['installmentName'] ?? data['title'] ?? '',
              dueDate: data['dueDate'] != null
                  ? switch (data['dueDate']) {
                      Timestamp date => date.toDate(),
                      String date => DateTime.tryParse(date) ?? DateTime.now(),
                      _ => DateTime.now(),
                    }
                  : DateTime.now(),
              totalAmount: (data['totalAmount'] ?? data['amount'] ?? 0)
                  .toDouble(),
              category: data['category'] ?? '',
              notes: data['notes'] ?? '',
              currency: data['currency'] ?? 'USD',
              isPaid: data['isPaid'] ?? (data['status'] == 'paid'),
              paidDate: data['paidDate'] != null
                  ? (data['paidDate'] as Timestamp).toDate()
                  : null,
              createdAt: data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
              icon: _getIconData(data['icon'] as int?),
              iconColor: data['iconColor'] != null
                  ? Color(data['iconColor'] as int)
                  : Colors.blue,
              timeStatus: (data['timeStatus'] ?? '').toString(),
            );
          }).toList();
        });
  }

  /// Add a new installment
  Future<String> addInstallment(InstallmentModel installment) async {
    if (_userId == null) throw Exception('User not authenticated');
    final docRef = await _firestore
        .collection('users')
        .doc(_userId)
        .collection(_installmentsCollection)
        .add({
          'installmentName': installment.installmentName.toString(),
          'dueDate': Timestamp.fromDate(installment.dueDate),
          'totalAmount': installment.totalAmount,
          'category': installment.category.toString(),
          'notes': installment.notes.toString(),
          'currency': installment.currency.toString(),
          'isPaid': installment.isPaid,
          'paidDate': installment.paidDate != null
              ? Timestamp.fromDate(installment.paidDate!)
              : null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'icon': _getIconCodePoint(installment.icon),
          'iconColor':
              installment.iconColor?.toARGB32() ?? Colors.blue.toARGB32(),
          'timeStatus': installment.timeStatus.toString(),
        });

    return docRef.id;
  }

  /// Update installment status (paid/unpaid)
  Future<void> updateInstallmentStatus(String id, bool isPaid) async {
    if (_userId == null) throw Exception('User not authenticated');
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection(_installmentsCollection)
        .doc(id)
        .update({
          'isPaid': isPaid,
          'paidDate': isPaid ? FieldValue.serverTimestamp() : null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Update installment details
  Future<void> updateInstallment(InstallmentModel installment) async {
    if (_userId == null) throw Exception('User not authenticated');
    if (installment.id == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection(_installmentsCollection)
        .doc(installment.id!)
        .update({
          'installmentName': installment.installmentName,
          'dueDate': installment.dueDate,
          'totalAmount': installment.totalAmount,
          'category': installment.category,
          'notes': installment.notes,
          'currency': installment.currency,
          'isPaid': installment.isPaid,
          'paidDate': installment.paidDate,
          'icon': installment.icon?.codePoint,
          'iconColor': installment.iconColor?.toARGB32(),
          'timeStatus': installment.timeStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Delete an installment
  Future<void> deleteInstallment(String id) async {
    if (_userId == null) throw Exception('User not authenticated');
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection(_installmentsCollection)
        .doc(id)
        .delete();
  }
}
