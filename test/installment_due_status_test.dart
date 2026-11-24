import 'package:flutter_test/flutter_test.dart';
import 'package:saveit/features/installments/domain/entities/installment.dart';

void main() {
  test('installment labels preserve the existing whole-day calculation', () {
    final now = DateTime(2026, 11, 24, 12);
    expect(
      installmentDueStatus(now.subtract(const Duration(hours: 25)), now),
      'Overdue',
    );
    expect(
      installmentDueStatus(now.subtract(const Duration(hours: 10)), now),
      'Due Today',
    );
    expect(
      installmentDueStatus(now.add(const Duration(hours: 25)), now),
      'Due Tomorrow',
    );
    expect(
      installmentDueStatus(now.add(const Duration(days: 3)), now),
      'In 3 days',
    );
  });
}
