import 'expenses_model.dart';

final List<Expense> dummyExpenses = [];
double get totalExpenses {
  return dummyExpenses.fold(0.0, (sum, item) => sum + item.amount);
}
