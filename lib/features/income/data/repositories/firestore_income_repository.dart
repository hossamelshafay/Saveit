import 'package:injectable/injectable.dart';
import 'package:saveit/features/income/domain/repositories/income_repository.dart';
import 'package:saveit/features/income/data/data_sources/income_source.dart';
import 'package:saveit/features/balance/domain/repositories/balance_repository.dart';

@LazySingleton(as: IncomeRepository)
class FirestoreIncomeRepository implements IncomeRepository {
  FirestoreIncomeRepository(this._source, this._balance);

  final IncomeSource _source;
  final BalanceRepository _balance;

  @override
  Stream<List<Map<String, dynamic>>> getUserIncomesStream() =>
      _source.getUserIncomesStream();

  @override
  Future<void> addIncome({
    required String title,
    required double amount,
    required String category,
    required String currency,
    required DateTime date,
    String? notes,
  }) async {
    await _source.addIncome(
      title: title,
      amount: amount,
      category: category,
      currency: currency,
      date: date,
      notes: notes,
    );
    await _balance.updateUserFinancials();
  }

  @override
  Future<bool> updateIncome({
    required String incomeId,
    required String title,
    required double amount,
    required String category,
    required String currency,
    required DateTime date,
    String? notes,
  }) async {
    final result = await _source.updateIncome(
      incomeId: incomeId,
      title: title,
      amount: amount,
      category: category,
      currency: currency,
      date: date,
      notes: notes,
    );
    if (result) await _balance.updateUserFinancials();
    return result;
  }

  @override
  Future<bool> deleteIncome(String incomeId) async {
    final result = await _source.deleteIncome(incomeId);
    if (result) await _balance.updateUserFinancials();
    return result;
  }
}
