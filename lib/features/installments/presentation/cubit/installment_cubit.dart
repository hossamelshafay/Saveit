import 'package:injectable/injectable.dart';
import 'package:saveit/core/utils/watch_cubit.dart';
import 'package:saveit/features/installments/domain/repositories/installment_repository.dart';
import 'package:saveit/features/installments/domain/entities/installment.dart';

@injectable
class InstallmentCubit extends WatchCubit<List<InstallmentModel>> {
  InstallmentCubit(this._repository);

  final InstallmentRepository _repository;

  void start() => watch(_repository.getInstallmentsStream());

  Future<void> save(InstallmentModel installment) async {
    final updated = installment.copyWith(
      timeStatus: installmentDueStatus(installment.dueDate, DateTime.now()),
    );
    if (installment.id == null) {
      await _repository.addInstallment(updated);
    } else {
      await _repository.updateInstallment(updated);
    }
  }

  Future<void> updateStatus(String id, bool isPaid) =>
      _repository.updateInstallmentStatus(id, isPaid);

  Future<void> delete(String id) => _repository.deleteInstallment(id);
}
