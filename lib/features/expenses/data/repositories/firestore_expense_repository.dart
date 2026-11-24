import 'package:injectable/injectable.dart';
import 'package:saveit/features/expenses/domain/repositories/expense_repository.dart';
import 'package:saveit/features/expenses/data/data_sources/expense_source.dart';
import 'package:saveit/features/expenses/domain/entities/expense.dart';
import 'package:saveit/features/balance/domain/repositories/balance_repository.dart';

@LazySingleton(as: ExpenseRepository)
class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository(this._source, this._balance);

  final ExpenseSource _source;
  final BalanceRepository _balance;

  @override
  Stream<List<Map<String, dynamic>>> getUserExpensesStream() =>
      _source.getUserExpensesStream();

  @override
  Future<void> addExpenseToFirebase(Expense expense, {String? notes}) async {
    await _source.addExpenseToFirebase(expense, notes: notes);
    await _balance.updateUserFinancials();
  }

  @override
  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required String currency,
    required String date,
    String? note,
  }) async {
    await _source.updateExpense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      currency: currency,
      date: date,
      note: note,
    );
    await _balance.updateUserFinancials();
  }

  @override
  Future<bool> deleteExpense(String expenseId) async {
    final result = await _source.deleteExpense(expenseId);
    if (result) await _balance.updateUserFinancials();
    return result;
  }
}
