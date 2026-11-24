import 'package:injectable/injectable.dart';
import 'package:saveit/core/utils/watch_cubit.dart';
import 'package:saveit/features/expenses/domain/repositories/expense_repository.dart';
import 'package:saveit/features/expenses/domain/entities/expense.dart';

@injectable
class ExpenseCubit extends WatchCubit<List<Map<String, dynamic>>> {
  ExpenseCubit(this._repository);

  final ExpenseRepository _repository;

  void start() => watch(_repository.getUserExpensesStream());

  Future<void> save({
    String? id,
    required Expense expense,
    required String currency,
    required String notes,
  }) {
    if (id == null) {
      return _repository.addExpenseToFirebase(expense, notes: notes);
    }
    return _repository.updateExpense(
      id: id,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      currency: currency,
      date: expense.date,
      note: notes.isEmpty ? null : notes,
    );
  }

  Future<bool> delete(String id) => _repository.deleteExpense(id);
}
