import 'package:flutter_test/flutter_test.dart';
import 'package:saveit/features/savings/domain/entities/savings.dart';

void main() {
  test(
    'daily savings measures yesterday’s spending minus today’s spending',
    () {
      final timestamp = DateTime(2026, 11, 24, 12);
      SavingsModel calculate(double today) => SavingsModel.fromExpenseTotals(
        todayExpenses: today,
        yesterdayExpenses: 100,
        timestamp: timestamp,
        date: '2026-11-24',
      );

      expect(calculate(70).difference, 30);
      expect(calculate(100).difference, 0);
      expect(calculate(125).difference, -25);
    },
  );
}
