import 'package:saveit/features/savings/domain/entities/savings.dart';

abstract interface class SavingsRepository {
  Stream<SavingsModel?> getSavingsStream();
  Future<List<Map<String, dynamic>>> getWeeklyExpenseData();
  Future<Map<String, dynamic>> getMonthlySavingsSummary();
  Future<SavingsModel?> calculateDailySavings(String userId);
}
