import 'package:injectable/injectable.dart';
import 'package:saveit/features/installments/domain/repositories/installment_repository.dart';
import 'package:saveit/features/installments/data/data_sources/installment_source.dart';
import 'package:saveit/features/installments/domain/entities/installment.dart';
import 'package:saveit/features/balance/domain/repositories/balance_repository.dart';

@LazySingleton(as: InstallmentRepository)
class FirestoreInstallmentRepository implements InstallmentRepository {
  FirestoreInstallmentRepository(this._source, this._balance);

  final InstallmentSource _source;
  final BalanceRepository _balance;

  @override
  Stream<List<InstallmentModel>> getInstallmentsStream() =>
      _source.getInstallmentsStream();

  @override
  Future<String> addInstallment(InstallmentModel installment) async {
    final result = await _source.addInstallment(installment);
    await _balance.updateUserFinancials();
    return result;
  }

  @override
  Future<void> updateInstallment(InstallmentModel installment) async {
    await _source.updateInstallment(installment);
    await _balance.updateUserFinancials();
  }

  @override
  Future<void> updateInstallmentStatus(String id, bool isPaid) async {
    await _source.updateInstallmentStatus(id, isPaid);
    await _balance.updateUserFinancials();
  }

  @override
  Future<void> deleteInstallment(String id) async {
    await _source.deleteInstallment(id);
    await _balance.updateUserFinancials();
  }
}
