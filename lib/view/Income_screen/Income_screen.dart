// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:saveit/core/services/income_service.dart';
import 'package:saveit/view/Add_new_income_screen/Add_new_income_screen.dart';

class income_screen extends StatefulWidget {
  const income_screen({super.key});

  @override
  State<income_screen> createState() => _income_screenState();
}

class _income_screenState extends State<income_screen> {
  final IncomeService _incomeService = IncomeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        title: Text(
          "income".tr,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _incomeService.getUserIncomesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final incomes = snapshot.data ?? [];
          if (incomes.isEmpty) {
            return Center(child: Text("no income added yet".tr));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incomes.length,
            itemBuilder: (context, index) {
              final income = incomes[index];
              final amount = (income["amount"] as num?)?.toDouble() ?? 0.00;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddNewIncomeScreen(
                          incomeId: income["id"] as String,
                          incomeData: income,
                        ),
                      ),
                    );
                  },
                  title: Text(income["title"] ?? "N/A"),
                  subtitle: Text(
                    income["notes"]?.isNotEmpty == true
                        ? "Noted ✓"
                        : "No notes",
                    style: TextStyle(
                      color: income["notes"]?.isNotEmpty == true
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: const Icon(Icons.account_balance_wallet, size: 32),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        amount.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final incomeId = income["id"] as String?;
                          if (incomeId != null) {
                            try {
                              await _incomeService.deleteIncome(incomeId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("income deleted".tr),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Failed to delete income: $e",
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewIncomeScreen(),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.add, size: 24, color: Colors.white),
            label: Text(
              "add_income".tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
