class SavingsModel {
  final double todayExpenses;
  final double yesterdayExpenses;
  final double difference;
  final DateTime timestamp;
  final String date;

  SavingsModel({
    required this.todayExpenses,
    required this.yesterdayExpenses,
    required this.difference,
    required this.timestamp,
    required this.date,
  });

  factory SavingsModel.fromFirestore(Map<String, dynamic> data) {
    return SavingsModel(
      todayExpenses: (data['todayExpenses'] ?? 0.0).toDouble(),
      yesterdayExpenses: (data['yesterdayExpenses'] ?? 0.0).toDouble(),
      difference: (data['difference'] ?? 0.0).toDouble(),
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      date: data['date'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'todayExpenses': todayExpenses,
      'yesterdayExpenses': yesterdayExpenses,
      'difference': difference,
      'timestamp': timestamp,
      'date': date,
    };
  }

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
