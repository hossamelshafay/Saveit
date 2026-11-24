import 'package:saveit/features/auth/presentation/screens/login_screen.dart';
import 'package:saveit/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';
import 'package:saveit/app/router/route_names.dart';
import 'package:saveit/app/router/route_guards.dart';
import 'package:saveit/app/router/app_router.dart';
import 'package:saveit/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:saveit/features/auth/presentation/cubit/account_cubit.dart';
import 'package:saveit/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:saveit/features/profile/domain/repositories/profile_repository.dart';
import 'package:saveit/features/balance/domain/repositories/balance_repository.dart';
import 'package:saveit/core/errors/exceptions.dart';

import 'dart:async';

void main() {
  late _Auth auth;
  late _Balance balance;
  late ProfileCubit profile;
  late GetIt dependencies;
  late RouteGuards guards;

  setUp(() {
    auth = _Auth();
    balance = _Balance();
    profile = ProfileCubit(_Profile());
    dependencies = GetIt.asNewInstance()
      ..registerFactory(() => AuthFormCubit(auth, profile, balance))
      ..registerFactory(() => AccountCubit(auth, _Profile()));
    guards = RouteGuards(auth);
  });

  tearDown(() async {
    guards.dispose();
    await auth.changes.close();
    await profile.close();
    await dependencies.reset();
  });

  testWidgets('signed-out protected routes redirect to the login page', (
    tester,
  ) async {
    final router = createAppRouter(dependencies, guards);
    addTearDown(router.dispose);
    router.go(RouteNames.income);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, RouteNames.login);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('login can open and return from password recovery', (
    tester,
  ) async {
    final router = createAppRouter(dependencies, guards);
    addTearDown(router.dispose);
    router.go(RouteNames.login);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    final signIn = find.text('Sign In');
    await tester.ensureVisible(signIn);
    await tester.pumpAndSettle();
    await tester.tap(signIn);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ForgotPasswordScreen), findsNothing);
  });

  test('restored sessions can enter protected routes and signed-out sessions cannot', () {
    expect(guards.afterSplash, RouteNames.login);
    expect(guards.redirect(RouteNames.settings), RouteNames.login);
    auth.session = (id: 'guest', isAnonymous: true);
    expect(guards.afterSplash, RouteNames.home);
    expect(guards.redirect(RouteNames.settings), isNull);
    auth.session = null;
    expect(guards.redirect(RouteNames.settings), RouteNames.login);
  });

  test(
    'unverified email feedback preserves the verification warning',
    () async {
      final cubit = AuthFormCubit(auth, profile, balance);
      addTearDown(cubit.close);
      auth.signInError = const ServiceException(
        'Please verify your email before signing in',
        'email-not-verified',
      );
      final failure = await cubit.login(' user@example.com ', ' password ');
      expect(failure?.title, 'Email Not Verified');
      expect(failure?.warning, isTrue);
      expect(balance.refreshes, 0);
      expect(cubit.state.isLoading, isFalse);
    },
  );

  test('anonymous login and registration keep their separate financial refresh rules', () async {
    final cubit = AuthFormCubit(auth, profile, balance);
    addTearDown(cubit.close);

    expect(await cubit.anonymous(registering: false), isNull);
    expect(balance.refreshes, 0);
    expect(await cubit.anonymous(registering: true), isNull);
    expect(balance.refreshes, 1);
  });
}

class _Auth extends Fake implements AuthRepository {
  final changes = StreamController<AuthSession?>.broadcast();

  @override
  AuthSession? session;
  ServiceException? signInError;

  @override
  Stream<AuthSession?> get sessionChanges => changes.stream;

  @override
  Future<bool> signIn(String email, String password) async {
    if (signInError case final error?) throw error;
    return true;
  }

  @override
  Future<bool> signInAnonymously() async => true;
}

class _Balance extends Fake implements BalanceRepository {
  int refreshes = 0;

  @override
  Future<void> updateUserFinancials() async => refreshes++;
}

class _Profile extends Fake implements ProfileRepository {}
