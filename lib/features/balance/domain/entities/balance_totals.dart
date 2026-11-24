class BalanceTotals {
  const BalanceTotals({
    required this.income,
    required this.expenses,
    required this.paidInstallments,
    required this.savings,
  });

  final double income;
  final double expenses;
  final double paidInstallments;
  final double savings;

  double get balance => income - expenses - paidInstallments + savings;
}
