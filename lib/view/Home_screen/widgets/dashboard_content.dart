import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';
import 'package:saveit/core/provider/firestore_service.dart';
import 'package:saveit/view/Expenses_screen/Expenses_screen.dart';
import 'package:saveit/view/Home_screen/widgets/grid_item.dart';
import 'package:saveit/view/Home_screen/widgets/remaining_balance_card.dart';
import 'package:saveit/view/Income_screen/Income_screen.dart';
import 'package:saveit/view/Installments_screen/Installments_screen.dart';
import 'package:saveit/view/Settings_screen/Settings_screen.dart';
import 'package:saveit/view/Savings_screen/Savings_screen.dart';
import 'package:flutter/services.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF4CAF50),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: const Color(0xFF4CAF50),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            title: StreamBuilder<Map<String, dynamic>>(
              stream: Provider.of<FirestoreService>(
                context,
                listen: false,
              ).getUserFinancialsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    "hello_user".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }

                final data = snapshot.data!;
                final username = data['username'] ?? "User";
                return Text(
                  "hello_name".trParams({"name": username}),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: StreamBuilder<Map<String, dynamic>>(
          stream: Provider.of<FirestoreService>(
            context,
            listen: false,
          ).getUserFinancialsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            final data = snapshot.data!;
            final income = (data['income'] ?? 0).toDouble();
            final expenses = (data['expenses'] ?? 0).toDouble();
            final totalInstallments = (data['totalInstallments'] ?? 0)
                .toDouble();
            final paidInstallments = (data['paidInstallments'] ?? 0).toDouble();
            final balance = (data['balance'] ?? 0).toDouble();
            final currency = data['currency'] ?? 'SAR';

            return Column(
              children: [
                RemainingBalanceCard(
                  balance: balance.toStringAsFixed(2),
                  currency: currency,
                  income: income.toStringAsFixed(2),
                  expenses: expenses.toStringAsFixed(2),
                  installmentsPaid: paidInstallments.toStringAsFixed(2),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16.0),
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    children: [
                      GridItem(
                        icon: Icons.arrow_downward_sharp,
                        title: 'income'.tr,
                        amount: '${income.toStringAsFixed(2)} $currency',
                        color: const Color(0xFF4CAF50),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => income_screen(),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                      GridItem(
                        icon: Icons.arrow_outward_sharp,
                        title: 'expense'.tr,
                        amount: '${expenses.toStringAsFixed(2)} $currency',
                        color: Colors.red,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExpensesScreen(),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                      GridItem(
                        icon: Icons.account_balance_wallet,
                        title: 'savings'.tr,
                        amount: 'click to know more',
                        color: Colors.blue,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavingsScreen(),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                      GridItem(
                        icon: Icons.payment,
                        title: 'installments'.tr,
                        amount:
                            '${totalInstallments.toStringAsFixed(2)} $currency',
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InstallmentsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
