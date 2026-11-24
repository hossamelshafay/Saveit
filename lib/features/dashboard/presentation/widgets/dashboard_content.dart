import 'package:saveit/app/localization/app_translations.dart';
import 'package:go_router/go_router.dart';
import 'package:saveit/app/router/route_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/balance/presentation/cubit/balance_cubit.dart';
import 'package:saveit/core/utils/watch_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/dashboard/presentation/widgets/grid_item.dart';
import 'package:saveit/features/dashboard/presentation/widgets/remaining_balance_card.dart';
import 'package:flutter/services.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

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
            title: BlocBuilder<BalanceCubit, WatchState<Map<String, dynamic>>>(
              builder: (context, snapshot) {
                if (snapshot.data == null && snapshot.error == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Text(
                    "hello_user".tr(context),
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
                  "hello_name".tr(context, {"name": username}),
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
                  context.push(RouteNames.settings);
                },
              ),
            ],
          ),
        ),
        body: BlocBuilder<BalanceCubit, WatchState<Map<String, dynamic>>>(
          builder: (context, snapshot) {
            if (snapshot.data == null && snapshot.error == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null || snapshot.data!.isEmpty) {
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
                        title: 'income'.tr(context),
                        amount: '${income.toStringAsFixed(2)} $currency',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          context.push(RouteNames.income);
                        },
                      ),
                      GridItem(
                        icon: Icons.arrow_outward_sharp,
                        title: 'expense'.tr(context),
                        amount: '${expenses.toStringAsFixed(2)} $currency',
                        color: Colors.red,
                        onTap: () {
                          context.push(RouteNames.expenses);
                        },
                      ),
                      GridItem(
                        icon: Icons.account_balance_wallet,
                        title: 'savings'.tr(context),
                        amount: 'click to know more',
                        color: Colors.blue,
                        onTap: () {
                          context.push(RouteNames.savings);
                        },
                      ),
                      GridItem(
                        icon: Icons.payment,
                        title: 'installments'.tr(context),
                        amount:
                            '${totalInstallments.toStringAsFixed(2)} $currency',
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          context.pushReplacement(RouteNames.installments);
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
