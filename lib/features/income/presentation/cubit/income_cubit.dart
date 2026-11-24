import 'package:injectable/injectable.dart';
import 'package:saveit/core/utils/watch_cubit.dart';
import 'package:saveit/features/income/domain/repositories/income_repository.dart';

@injectable
class IncomeCubit extends WatchCubit<List<Map<String, dynamic>>> {
  IncomeCubit(this._repository);

  final IncomeRepository _repository;

  void start() => watch(_repository.getUserIncomesStream());

  Future<bool> save({
    String? id,
    required String title,
    required double amount,
    required String category,
    required String currency,
    required DateTime date,
    String? notes,
  }) async {
    if (id != null) {
      return _repository.updateIncome(
        incomeId: id,
        title: title,
        amount: amount,
        category: category,
        currency: currency,
        date: date,
        notes: notes,
      );
    }
    await _repository.addIncome(
      title: title,
      amount: amount,
      category: category,
      currency: currency,
      date: date,
      notes: notes,
    );
    return true;
  }

  Future<bool> delete(String id) => _repository.deleteIncome(id);
}
