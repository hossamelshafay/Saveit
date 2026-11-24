// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/data_sources/firebase_auth_source.dart'
    as _i321;
import '../../features/auth/data/repositories/firebase_auth_repository.dart'
    as _i900;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/cubit/account_cubit.dart' as _i624;
import '../../features/auth/presentation/cubit/auth_form_cubit.dart' as _i0;
import '../../features/balance/data/data_sources/financial_totals_source.dart'
    as _i327;
import '../../features/balance/data/repositories/firestore_balance_repository.dart'
    as _i352;
import '../../features/balance/domain/repositories/balance_repository.dart'
    as _i588;
import '../../features/balance/presentation/cubit/balance_cubit.dart' as _i599;
import '../../features/chat/data/data_sources/chat_history_source.dart'
    as _i135;
import '../../features/chat/data/data_sources/chat_reply_source.dart' as _i379;
import '../../features/chat/data/repositories/local_chat_repository.dart'
    as _i1044;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i420;
import '../../features/chat/presentation/cubit/chat_cubit.dart' as _i305;
import '../../features/expenses/data/data_sources/expense_source.dart' as _i61;
import '../../features/expenses/data/repositories/firestore_expense_repository.dart'
    as _i725;
import '../../features/expenses/domain/repositories/expense_repository.dart'
    as _i939;
import '../../features/expenses/presentation/cubit/expense_cubit.dart' as _i230;
import '../../features/income/data/data_sources/income_source.dart' as _i432;
import '../../features/income/data/repositories/firestore_income_repository.dart'
    as _i338;
import '../../features/income/domain/repositories/income_repository.dart'
    as _i260;
import '../../features/income/presentation/cubit/income_cubit.dart' as _i1006;
import '../../features/installments/data/data_sources/installment_source.dart'
    as _i433;
import '../../features/installments/data/repositories/firestore_installment_repository.dart'
    as _i980;
import '../../features/installments/domain/repositories/installment_repository.dart'
    as _i231;
import '../../features/installments/presentation/cubit/installment_cubit.dart'
    as _i457;
import '../../features/profile/data/data_sources/profile_source.dart' as _i831;
import '../../features/profile/data/repositories/firestore_profile_repository.dart'
    as _i973;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/presentation/cubit/profile_cubit.dart' as _i36;
import '../../features/savings/data/data_sources/savings_source.dart' as _i50;
import '../../features/savings/data/repositories/firestore_savings_repository.dart'
    as _i694;
import '../../features/savings/domain/repositories/savings_repository.dart'
    as _i116;
import '../../features/savings/presentation/cubit/savings_cubit.dart' as _i386;
import '../../features/settings/presentation/cubit/settings_cubit.dart'
    as _i792;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i321.FirebaseAuthSource>(
      () => _i321.FirebaseAuthSource(),
    );
    gh.lazySingleton<_i327.FinancialTotalsSource>(
      () => _i327.FinancialTotalsSource(),
    );
    gh.lazySingleton<_i135.ChatHistorySource>(() => _i135.ChatHistorySource());
    gh.lazySingleton<_i379.ChatReplySource>(() => _i379.ChatReplySource());
    gh.lazySingleton<_i61.ExpenseSource>(() => _i61.ExpenseSource());
    gh.lazySingleton<_i432.IncomeSource>(() => _i432.IncomeSource());
    gh.lazySingleton<_i433.InstallmentSource>(() => _i433.InstallmentSource());
    gh.lazySingleton<_i831.ProfileSource>(() => _i831.ProfileSource());
    gh.lazySingleton<_i50.SavingsSource>(() => _i50.SavingsSource());
    gh.lazySingleton<_i792.SettingsCubit>(() => _i792.SettingsCubit());
    gh.lazySingleton<_i588.BalanceRepository>(
      () => _i352.FirestoreBalanceRepository(gh<_i327.FinancialTotalsSource>()),
    );
    gh.factory<_i599.BalanceCubit>(
      () => _i599.BalanceCubit(gh<_i588.BalanceRepository>()),
    );
    gh.lazySingleton<_i260.IncomeRepository>(
      () => _i338.FirestoreIncomeRepository(
        gh<_i432.IncomeSource>(),
        gh<_i588.BalanceRepository>(),
      ),
    );
    gh.lazySingleton<_i231.InstallmentRepository>(
      () => _i980.FirestoreInstallmentRepository(
        gh<_i433.InstallmentSource>(),
        gh<_i588.BalanceRepository>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i900.FirebaseAuthRepository(gh<_i321.FirebaseAuthSource>()),
    );
    gh.lazySingleton<_i939.ExpenseRepository>(
      () => _i725.FirestoreExpenseRepository(
        gh<_i61.ExpenseSource>(),
        gh<_i588.BalanceRepository>(),
      ),
    );
    gh.lazySingleton<_i420.ChatRepository>(
      () => _i1044.LocalChatRepository(
        gh<_i135.ChatHistorySource>(),
        gh<_i379.ChatReplySource>(),
      ),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i973.FirestoreProfileRepository(gh<_i831.ProfileSource>()),
    );
    gh.factory<_i230.ExpenseCubit>(
      () => _i230.ExpenseCubit(gh<_i939.ExpenseRepository>()),
    );
    gh.factory<_i624.AccountCubit>(
      () => _i624.AccountCubit(
        gh<_i787.AuthRepository>(),
        gh<_i894.ProfileRepository>(),
      ),
    );
    gh.factory<_i1006.IncomeCubit>(
      () => _i1006.IncomeCubit(gh<_i260.IncomeRepository>()),
    );
    gh.lazySingleton<_i116.SavingsRepository>(
      () => _i694.FirestoreSavingsRepository(gh<_i50.SavingsSource>()),
    );
    gh.factory<_i457.InstallmentCubit>(
      () => _i457.InstallmentCubit(gh<_i231.InstallmentRepository>()),
    );
    gh.factory<_i305.ChatCubit>(
      () => _i305.ChatCubit(
        gh<_i420.ChatRepository>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i386.SavingsCubit>(
      () => _i386.SavingsCubit(
        gh<_i116.SavingsRepository>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i36.ProfileCubit>(
      () => _i36.ProfileCubit(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i0.AuthFormCubit>(
      () => _i0.AuthFormCubit(
        gh<_i787.AuthRepository>(),
        gh<_i36.ProfileCubit>(),
        gh<_i588.BalanceRepository>(),
      ),
    );
    return this;
  }
}
