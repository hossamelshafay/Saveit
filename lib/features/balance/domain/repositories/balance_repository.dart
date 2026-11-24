abstract interface class BalanceRepository {
  Stream<Map<String, dynamic>> watchFinancials();
  Future<void> updateUserFinancials();
}
