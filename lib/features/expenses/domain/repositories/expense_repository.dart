import 'package:saveit/features/expenses/domain/entities/expense.dart';

abstract interface class ExpenseRepository {
  Stream<List<Map<String, dynamic>>> getUserExpensesStream();
  Future<void> addExpenseToFirebase(Expense expense, {String? notes});
  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required String currency,
    required String date,
    String? note,
  });
  Future<bool> deleteExpense(String expenseId);
}
