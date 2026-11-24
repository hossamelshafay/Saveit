abstract interface class IncomeRepository {
  Stream<List<Map<String, dynamic>>> getUserIncomesStream();
  Future<void> addIncome({
    required String title,
    required double amount,
    required String category,
    required String currency,
    required DateTime date,
    String? notes,
  });
  Future<bool> updateIncome({
    required String incomeId,
    required String title,
    required double amount,
    required String category,
    required String currency,
    required DateTime date,
    String? notes,
  });
  Future<bool> deleteIncome(String incomeId);
}
