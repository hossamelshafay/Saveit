import 'package:saveit/features/savings/domain/entities/savings.dart';

SavingsModel decodeSavings(Map<String, dynamic> data) {
  return SavingsModel(
    todayExpenses: (data['todayExpenses'] ?? 0.0).toDouble(),
    yesterdayExpenses: (data['yesterdayExpenses'] ?? 0.0).toDouble(),
    difference: (data['difference'] ?? 0.0).toDouble(),
    timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
    date: data['date'] ?? '',
  );
}

Map<String, dynamic> encodeSavings(SavingsModel savings) {
  return {
    'todayExpenses': savings.todayExpenses,
    'yesterdayExpenses': savings.yesterdayExpenses,
    'difference': savings.difference,
    'timestamp': savings.timestamp,
    'date': savings.date,
  };
}
