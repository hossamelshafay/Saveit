import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:saveit/app/di/injection.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';
import 'package:saveit/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:saveit/features/auth/presentation/cubit/account_cubit.dart';
import 'package:saveit/features/balance/domain/repositories/balance_repository.dart';
import 'package:saveit/features/balance/presentation/cubit/balance_cubit.dart';
import 'package:saveit/features/chat/domain/repositories/chat_repository.dart';
import 'package:saveit/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:saveit/features/expenses/domain/repositories/expense_repository.dart';
import 'package:saveit/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:saveit/features/income/domain/repositories/income_repository.dart';
import 'package:saveit/features/income/presentation/cubit/income_cubit.dart';
import 'package:saveit/features/installments/domain/repositories/installment_repository.dart';
import 'package:saveit/features/installments/presentation/cubit/installment_cubit.dart';
import 'package:saveit/features/profile/domain/repositories/profile_repository.dart';
import 'package:saveit/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:saveit/features/savings/domain/repositories/savings_repository.dart';
import 'package:saveit/features/savings/presentation/cubit/savings_cubit.dart';
import 'package:saveit/features/settings/presentation/cubit/settings_cubit.dart';

void main() {
  test(
    'production wiring registers repositories and route ViewModels',
    () async {
      final dependencies = configureDependencies(GetIt.asNewInstance());
      addTearDown(dependencies.reset);

      for (final type in [
        AuthRepository,
        AuthFormCubit,
        AccountCubit,
        BalanceRepository,
        BalanceCubit,
        ChatRepository,
        ChatCubit,
        ExpenseRepository,
        ExpenseCubit,
        IncomeRepository,
        IncomeCubit,
        InstallmentRepository,
        InstallmentCubit,
        ProfileRepository,
        ProfileCubit,
        SavingsRepository,
        SavingsCubit,
        SettingsCubit,
      ]) {
        expect(dependencies.isRegistered(type: type), isTrue, reason: '$type');
      }
    },
  );
}
