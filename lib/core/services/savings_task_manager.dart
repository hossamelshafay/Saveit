import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'savings_service.dart';

class SavingsTaskManager {
  static Timer? _dailyTimer;
  static DateTime? _lastCalculationDate;
  static const Duration _checkInterval = Duration(
    minutes: 30,
  ); // Check every 30 minutes

  /// Initialize the task manager
  static void initialize() {
    _startPeriodicCheck();
  }

  /// Start periodic checking for daily savings calculation
  static void _startPeriodicCheck() {
    _dailyTimer?.cancel();

    _dailyTimer = Timer.periodic(_checkInterval, (timer) {
      _checkAndCalculateDailySavings();
    });

    // Also run immediately on startup
    _checkAndCalculateDailySavings();
  }

  /// Check if daily savings calculation is needed
  static Future<void> _checkAndCalculateDailySavings() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Only calculate once per day
      if (_lastCalculationDate != null &&
          _lastCalculationDate!.isAtSameMomentAs(today)) {
        return;
      }

      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Only calculate after 12:01 AM
      if (now.hour == 0 && now.minute >= 1) {
        final savingsService = SavingsService();
        await savingsService.calculateDailySavings(user.uid);
        _lastCalculationDate = today;

        debugPrint('Daily savings calculated for ${user.uid} at $now');
      }
    } catch (e) {
      debugPrint('Error in daily savings calculation: $e');
    }
  }

  /// Manually trigger daily savings calculation
  static Future<void> triggerManualCalculation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final savingsService = SavingsService();
      await savingsService.calculateDailySavings(user.uid);
      _lastCalculationDate = DateTime.now();
    }
  }

  /// Stop the task manager
  static void dispose() {
    _dailyTimer?.cancel();
    _dailyTimer = null;
  }

  /// Reset calculation date (useful for testing)
  static void resetCalculationDate() {
    _lastCalculationDate = null;
  }
}
