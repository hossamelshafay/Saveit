import 'package:injectable/injectable.dart';
import 'package:saveit/features/balance/domain/repositories/balance_repository.dart';
import 'package:saveit/features/balance/data/data_sources/financial_totals_source.dart';

@LazySingleton(as: BalanceRepository)
class FirestoreBalanceRepository implements BalanceRepository {
  FirestoreBalanceRepository(this._source);

  final FinancialTotalsSource _source;

  @override
  Stream<Map<String, dynamic>> watchFinancials() =>
      _source.getUserFinancialsStream();

  @override
  Future<void> updateUserFinancials() => _source.updateUserFinancials();
}
