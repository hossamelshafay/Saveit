import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../model/savings_model.dart';

class SavingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;
  String? get userId => _auth.currentUser?.uid;

  /// Calculate daily savings and save to Firestore
  Future<SavingsModel?> calculateDailySavings(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      // Format dates as strings (yyyy-MM-dd)
      final todayStr = DateFormat('yyyy-MM-dd').format(today);

      // Get today's expenses
      final todayExpensesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .where(
            'date',
            isLessThan: Timestamp.fromDate(today.add(const Duration(days: 1))),
          )
          .get();

      double todayExpenses = 0.0;
      for (var doc in todayExpensesQuery.docs) {
        todayExpenses += (doc.data()['amount'] ?? 0.0).toDouble();
      }

      // Get yesterday's expenses
      final yesterdayExpensesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(yesterday))
          .where('date', isLessThan: Timestamp.fromDate(today))
          .get();

      double yesterdayExpenses = 0.0;
      for (var doc in yesterdayExpensesQuery.docs) {
        yesterdayExpenses += (doc.data()['amount'] ?? 0.0).toDouble();
      }

      // Calculate difference (yesterday - today, positive means savings)
      final difference = yesterdayExpenses - todayExpenses;

      // Create savings model
      final savings = SavingsModel(
        todayExpenses: todayExpenses,
        yesterdayExpenses: yesterdayExpenses,
        difference: difference,
        timestamp: now,
        date: todayStr,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savings')
          .doc(todayStr)
          .set(savings.toFirestore(), SetOptions(merge: true));

      return savings;
    } catch (e) {
      print('Error calculating daily savings: $e');
      return null;
    }
  }

  /// Get today's savings data
  Future<SavingsModel?> getTodaysSavings() async {
    try {
      if (_userId == null) return null;

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('savings')
          .doc(today)
          .get();

      if (doc.exists) {
        return SavingsModel.fromFirestore(doc.data()!);
      }

      // If no data exists for today, calculate it
      return await calculateDailySavings(_userId!);
    } catch (e) {
      print('Error getting today\'s savings: $e');
      return null;
    }
  }

  /// Get last 7 days of expense data for chart
  Future<List<Map<String, dynamic>>> getWeeklyExpenseData() async {
    try {
      if (_userId == null) return [];

      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 6));
      final startOfWeek = DateTime(
        sevenDaysAgo.year,
        sevenDaysAgo.month,
        sevenDaysAgo.day,
      );

      final expensesQuery = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek),
          )
          .orderBy('date')
          .get();

      // Group expenses by date
      Map<String, double> dailyExpenses = {};

      // Initialize all days with 0
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        dailyExpenses[dateStr] = 0.0;
      }

      // Add actual expenses
      for (var doc in expensesQuery.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final amount = (data['amount'] ?? 0.0).toDouble();

        if (dailyExpenses.containsKey(dateStr)) {
          dailyExpenses[dateStr] = dailyExpenses[dateStr]! + amount;
        }
      }

      // Convert to list format for chart
      return dailyExpenses.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        return {
          'date': entry.key,
          'amount': entry.value,
          'dayName': DateFormat('E').format(date), // Mon, Tue, etc.
          'dayNumber': date.day,
        };
      }).toList();
    } catch (e) {
      print('Error getting weekly expense data: $e');
      return [];
    }
  }

  /// Stream of savings data
  Stream<SavingsModel?> getSavingsStream() {
    if (_userId == null) return Stream.value(null);

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('savings')
        .doc(today)
        .snapshots()
        .asyncMap((doc) async {
          if (doc.exists) {
            return SavingsModel.fromFirestore(doc.data()!);
          }
          // Calculate if doesn't exist
          return await calculateDailySavings(_userId!);
        });
  }

  /// Get monthly savings summary
  Future<Map<String, dynamic>> getMonthlySavingsSummary() async {
    try {
      if (_userId == null) return {};

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final monthStr = DateFormat('yyyy-MM').format(now);

      final savingsQuery = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('savings')
          .where(
            'date',
            isGreaterThanOrEqualTo: DateFormat(
              'yyyy-MM-dd',
            ).format(startOfMonth),
          )
          .get();

      double totalSavings = 0.0;
      double totalExpenses = 0.0;
      int daysWithSavings = 0;
      int daysWithLosses = 0;

      for (var doc in savingsQuery.docs) {
        final data = doc.data();
        final difference = (data['difference'] ?? 0.0).toDouble();
        final todayExpenses = (data['todayExpenses'] ?? 0.0).toDouble();

        totalExpenses += todayExpenses;

        if (difference > 0) {
          totalSavings += difference;
          daysWithSavings++;
        } else if (difference < 0) {
          daysWithLosses++;
        }
      }

      return {
        'totalSavings': totalSavings,
        'totalExpenses': totalExpenses,
        'daysWithSavings': daysWithSavings,
        'daysWithLosses': daysWithLosses,
        'averageDaily':
            totalExpenses /
            (savingsQuery.docs.isNotEmpty ? savingsQuery.docs.length : 1),
        'month': monthStr,
      };
    } catch (e) {
      print('Error getting monthly savings summary: $e');
      return {};
    }
  }
}
