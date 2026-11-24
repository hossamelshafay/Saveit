import 'package:injectable/injectable.dart';
import 'package:saveit/features/savings/domain/repositories/savings_repository.dart';
import 'package:saveit/features/savings/data/data_sources/savings_source.dart';
import 'package:saveit/features/savings/domain/entities/savings.dart';

@LazySingleton(as: SavingsRepository)
class FirestoreSavingsRepository implements SavingsRepository {
  FirestoreSavingsRepository(this._source);

  final SavingsSource _source;

  @override
  Stream<SavingsModel?> getSavingsStream() => _source.getSavingsStream();

  @override
  Future<List<Map<String, dynamic>>> getWeeklyExpenseData() =>
      _source.getWeeklyExpenseData();

  @override
  Future<Map<String, dynamic>> getMonthlySavingsSummary() =>
      _source.getMonthlySavingsSummary();

  @override
  Future<SavingsModel?> calculateDailySavings(String userId) =>
      _source.calculateDailySavings(userId);
}
