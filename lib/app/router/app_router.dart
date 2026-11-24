import 'package:saveit/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:saveit/app/router/route_names.dart';
import 'package:saveit/app/router/route_guards.dart';
import 'package:saveit/features/splash/presentation/screens/splash_screen.dart';
import 'package:saveit/features/dashboard/presentation/screens/home_screen.dart';
import 'package:saveit/features/settings/presentation/screens/settings_screen.dart';
import 'package:saveit/features/profile/presentation/screens/profile_screen.dart';
import 'package:saveit/features/profile/presentation/screens/personal_info_screen.dart';
import 'package:saveit/features/profile/presentation/screens/change_password_screen.dart';
import 'package:saveit/features/profile/presentation/screens/delete_account_screen.dart';
import 'package:saveit/features/balance/presentation/screens/balance_screen.dart';
import 'package:saveit/features/income/presentation/screens/income_screen.dart';
import 'package:saveit/features/income/presentation/screens/income_form_screen.dart';
import 'package:saveit/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:saveit/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:saveit/features/installments/presentation/screens/installments_screen.dart';
import 'package:saveit/features/installments/presentation/screens/installment_form_screen.dart';
import 'package:saveit/features/savings/presentation/screens/savings_screen.dart';
import 'package:saveit/features/auth/presentation/screens/login_screen.dart';
import 'package:saveit/features/auth/presentation/screens/register_screen.dart';
import 'package:saveit/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:saveit/features/income/presentation/cubit/income_cubit.dart';
import 'package:saveit/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:saveit/features/installments/presentation/cubit/installment_cubit.dart';
import 'package:saveit/features/balance/presentation/cubit/balance_cubit.dart';
import 'package:saveit/features/savings/presentation/cubit/savings_cubit.dart';
import 'package:saveit/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:saveit/features/auth/presentation/cubit/account_cubit.dart';
import 'package:saveit/features/installments/domain/entities/installment.dart';

GoRouter createAppRouter(GetIt dependencies, RouteGuards guards) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: guards,
    redirect: (_, state) => guards.redirect(state.uri.path),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) => SplashScreen(
          onFinished: (context) => context.go(guards.afterSplash),
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (_, state) => _fade(
          state,
          BlocProvider(
            create: (_) => dependencies<AuthFormCubit>(),
            child: const LoginPage(),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (_, state) => _fade(
          state,
          BlocProvider(
            create: (_) => dependencies<AuthFormCubit>(),
            child: const RegisterPage(),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (_, state) => _fade(
          state,
          BlocProvider(
            create: (_) => dependencies<AccountCubit>(),
            child: const ForgotPasswordScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.home,
        pageBuilder: (_, state) => _fade(
          state,
          BlocProvider(
            create: (_) => dependencies<BalanceCubit>()..start(),
            child: HomeScreen(createChatCubit: () => dependencies<ChatCubit>()),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, _) => BlocProvider(
          create: (_) => dependencies<AccountCubit>(),
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.help,
        pageBuilder: (_, state) => _fade(state, const HelpSupportPage()),
      ),
      GoRoute(
        path: RouteNames.about,
        pageBuilder: (_, state) => _fade(state, const AboutPage()),
      ),
      GoRoute(
        path: RouteNames.profile,
        pageBuilder: (_, state) => _fade(state, const ProfilePage()),
      ),
      GoRoute(
        path: RouteNames.personalInfo,
        pageBuilder: (_, state) => _fade(state, const PersonalInfoPage()),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        pageBuilder: (_, state) => _fade(
          state,
          BlocProvider(
            create: (_) => dependencies<AccountCubit>(),
            child: const ChangePasswordPage(),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.deleteAccount,
        pageBuilder: (_, state) => _fade(
          state,
          BlocProvider(
            create: (_) => dependencies<AccountCubit>(),
            child: const DeleteAccountPage(),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.balance,
        builder: (_, _) => BlocProvider(
          create: (_) => dependencies<BalanceCubit>()..start(),
          child: const BalanceScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.income,
        builder: (_, _) => BlocProvider(
          create: (_) => dependencies<IncomeCubit>()..start(),
          child: const IncomeScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.incomeForm,
        builder: (_, state) {
          final income = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (_) => dependencies<IncomeCubit>(),
            child: AddNewIncomeScreen(
              incomeId: income?['id'] as String?,
              incomeData: income,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.expenses,
        builder: (_, _) => BlocProvider(
          create: (_) => dependencies<ExpenseCubit>()..start(),
          child: const ExpensesScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.expenseForm,
        builder: (_, state) {
          final expense = state.extra as Map<String, dynamic>?;
          return BlocProvider(
            create: (_) => dependencies<ExpenseCubit>(),
            child: AddExpenseScreen(
              expenseId: expense?['id'] as String?,
              expenseData: expense,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.installments,
        builder: (_, _) => BlocProvider(
          create: (_) => dependencies<InstallmentCubit>(),
          child: const InstallmentsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.installmentForm,
        builder: (_, state) => BlocProvider(
          create: (_) => dependencies<InstallmentCubit>(),
          child: AddInstallmentScreen(
            installmentToEdit: state.extra as InstallmentModel?,
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.savings,
        builder: (_, _) => BlocProvider(
          create: (_) => dependencies<SavingsCubit>()..start(),
          child: const SavingsScreen(),
        ),
      ),
    ],
  );
}

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    child: child,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
