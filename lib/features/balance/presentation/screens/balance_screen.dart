import 'package:saveit/app/localization/app_translations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/balance/presentation/cubit/balance_cubit.dart';
import 'package:saveit/core/utils/watch_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/balance/presentation/widgets/balance_info_card.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Balance'.tr(context),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: BlocBuilder<BalanceCubit, WatchState<Map<String, dynamic>>>(
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          final income = (data['income'] ?? 0).toDouble();
          final expenses = (data['expenses'] ?? 0).toDouble();
          final balance = (data['balance'] ?? 0).toDouble();
          final paidInstallments = (data['paidInstallments'] ?? 0).toDouble();
          final currency = data['currency'] ?? 'SAR';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Total Balance Card
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Your Balance'.tr(context),
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$currency ${balance.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Income, Expenses, and Paid Installments cards
                BalanceInfoCard(
                  title: 'income'.tr(context),
                  amount: income,
                  currency: currency,
                  textColor: Colors.green[700],
                  icon: Icons.arrow_upward,
                ),
                BalanceInfoCard(
                  title: 'expenses'.tr(context),
                  amount: expenses,
                  currency: currency,
                  textColor: Colors.red[700],
                  icon: Icons.arrow_downward,
                ),
                BalanceInfoCard(
                  title: 'paid_installments'.tr(context),
                  amount: paidInstallments,
                  currency: currency,
                  textColor: Colors.orange[700],
                  icon: Icons.payment,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
