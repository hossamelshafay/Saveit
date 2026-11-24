import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saveit/features/savings/data/data_sources/savings_source.dart';

class SavingsWorkManager {
  static const String _dailySavingsTask = "daily_savings_calculation";
  static const String _uniqueName = "daily_savings_unique";

  /// Initialize WorkManager and register periodic task
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);

    await scheduleDailySavingsTask();
  }

  /// Schedule daily savings calculation task
  static Future<void> scheduleDailySavingsTask() async {
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      _dailySavingsTask,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Calculate delay until next midnight
  static Duration _calculateInitialDelay() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }

  /// Cancel all scheduled tasks
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }

  /// Cancel specific daily savings task
  static Future<void> cancelDailySavingsTask() async {
    await Workmanager().cancelByUniqueName(_uniqueName);
  }
}

/// Background task callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final savingsService = SavingsSource();
        await savingsService.calculateDailySavings(user.uid);
        debugPrint(
          'Daily savings calculated successfully for user: ${user.uid}',
        );
      } else {
        debugPrint('No authenticated user found for daily savings calculation');
      }

      return true;
    } catch (e) {
      debugPrint('Error in daily savings background task: $e');
      return false;
    }
  });
}
