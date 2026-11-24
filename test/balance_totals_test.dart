import 'package:flutter_test/flutter_test.dart';
import 'package:saveit/features/balance/domain/entities/balance_totals.dart';

void main() {
  test('balance adds savings and subtracts paid installments from income', () {
    const totals = BalanceTotals(
      income: 1000,
      expenses: 250,
      paidInstallments: 400,
      savings: 50,
    );
    expect(totals.balance, 400);
  });

  test('overspending can produce a negative balance', () {
    const totals = BalanceTotals(
      income: 10,
      expenses: 20,
      paidInstallments: 5,
      savings: 0,
    );
    expect(totals.balance, -15);
  });
}
