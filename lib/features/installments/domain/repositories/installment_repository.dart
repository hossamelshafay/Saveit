import 'package:saveit/features/installments/domain/entities/installment.dart';

abstract interface class InstallmentRepository {
  Stream<List<InstallmentModel>> getInstallmentsStream();
  Future<String> addInstallment(InstallmentModel installment);
  Future<void> updateInstallment(InstallmentModel installment);
  Future<void> updateInstallmentStatus(String id, bool isPaid);
  Future<void> deleteInstallment(String id);
}
