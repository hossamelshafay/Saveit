import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/savings_service.dart';
import '../services/savings_task_manager.dart';
import '../view/Savings_screen/Savings_screen.dart';

/// Demo usage of the SavingsScreen and related services
class SavingsDemo {
  /// Initialize the savings functionality
  static Future<void> initialize() async {
    // Initialize Firebase (should already be done in main.dart)
    await Firebase.initializeApp();

    // Initialize the background task manager
    SavingsTaskManager.initialize();

    print('Savings functionality initialized successfully!');
  }

  /// Manually trigger savings calculation (useful for testing)
  static Future<void> calculateSavingsManually() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found');
      return;
    }

    final savingsService = SavingsService();
    final result = await savingsService.calculateDailySavings(user.uid);

    if (result != null) {
      print('Daily savings calculated successfully:');
      print('Today\'s expenses: ${result.todayExpenses}');
      print('Yesterday\'s expenses: ${result.yesterdayExpenses}');
      print('Difference: ${result.difference}');
      print('Message: ${result.savingsMessage}');
    } else {
      print('Failed to calculate daily savings');
    }
  }

  /// Navigate to Savings Screen (use this in your app navigation)
  static void navigateToSavingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavingsScreen()),
    );
  }

  /// Example of how to get savings data programmatically
  static Future<void> getSavingsData() async {
    final savingsService = SavingsService();

    // Get today's savings
    final todaysSavings = await savingsService.getTodaysSavings();
    if (todaysSavings != null) {
      print('Today\'s savings data: ${todaysSavings.savingsMessage}');
    }

    // Get weekly expense trend
    final weeklyData = await savingsService.getWeeklyExpenseData();
    print('Weekly expense data points: ${weeklyData.length}');

    // Get monthly summary
    final monthlySummary = await savingsService.getMonthlySavingsSummary();
    print('Monthly summary: $monthlySummary');
  }
}

/// Example widget showing how to integrate the savings screen
class SavingsIntegrationExample extends StatelessWidget {
  const SavingsIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Integration Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => SavingsDemo.navigateToSavingsScreen(context),
              child: const Text('Open Savings Screen'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: SavingsDemo.calculateSavingsManually,
              child: const Text('Calculate Savings Manually'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: SavingsDemo.getSavingsData,
              child: const Text('Get Savings Data'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Usage Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '1. The savings calculation runs automatically every day at midnight\n'
                '2. Click "Open Savings Screen" to view the savings dashboard\n'
                '3. The screen shows daily comparison, weekly trends, and monthly summary\n'
                '4. Data is automatically synced with Firebase Firestore\n'
                '5. Users get motivational messages based on their savings performance',
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
