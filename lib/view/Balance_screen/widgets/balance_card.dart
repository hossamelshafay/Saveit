import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:provider/provider.dart';
import '../../../core/provider/firestore_service.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return StreamBuilder<Map<String, dynamic>>(
      stream: firestoreService.getUserFinancialsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "No financial data yet",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          );
        }

        final userData = snapshot.data!;
        final balance = (userData['balance'] ?? 0).toDouble();
        final income = (userData['income'] ?? 0).toDouble();
        final expenses = (userData['expenses'] ?? 0).toDouble();
        final savings = (userData['savings'] ?? 0).toDouble();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Balance'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "SAR ${balance.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${'income'.tr}: SAR ${income.toStringAsFixed(2)}"),
                    Text("${'expense'.tr}: SAR ${expenses.toStringAsFixed(2)}"),
                    Text("${'savings'.tr}: SAR ${savings.toStringAsFixed(2)}"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
