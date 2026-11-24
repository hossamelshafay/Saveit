class SavingsModel {
  final double todayExpenses;
  final double yesterdayExpenses;
  final double difference;
  final DateTime timestamp;
  final String date;

  const SavingsModel({
    required this.todayExpenses,
    required this.yesterdayExpenses,
    required this.difference,
    required this.timestamp,
    required this.date,
  });

  factory SavingsModel.fromExpenseTotals({
    required double todayExpenses,
    required double yesterdayExpenses,
    required DateTime timestamp,
    required String date,
  }) => SavingsModel(
    todayExpenses: todayExpenses,
    yesterdayExpenses: yesterdayExpenses,
    difference: yesterdayExpenses - todayExpenses,
    timestamp: timestamp,
    date: date,
  );

  String get savingsMessage {
    if (difference > 0) {
      return "Great! You saved ${difference.abs().toStringAsFixed(2)} SAR today 👏";
    } else if (difference < 0) {
      return "You spent ${difference.abs().toStringAsFixed(2)} SAR more today 🔴";
    } else {
      return "Your spending today matches yesterday ⚪";
    }
  }
}
