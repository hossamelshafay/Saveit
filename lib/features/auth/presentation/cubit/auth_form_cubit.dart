import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';
import 'package:saveit/features/balance/domain/repositories/balance_repository.dart';
import 'package:saveit/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:saveit/core/errors/failures.dart';
import 'package:saveit/core/errors/error_handler.dart';

class AuthFormState {
  const AuthFormState({
    this.isLoading = false,
    this.passwordHidden = true,
    this.confirmPasswordHidden = true,
    this.termsAccepted = false,
  });

  final bool isLoading;
  final bool passwordHidden;
  final bool confirmPasswordHidden;
  final bool termsAccepted;

  AuthFormState copyWith({
    bool? isLoading,
    bool? passwordHidden,
    bool? confirmPasswordHidden,
    bool? termsAccepted,
  }) => AuthFormState(
    isLoading: isLoading ?? this.isLoading,
    passwordHidden: passwordHidden ?? this.passwordHidden,
    confirmPasswordHidden: confirmPasswordHidden ?? this.confirmPasswordHidden,
    termsAccepted: termsAccepted ?? this.termsAccepted,
  );
}

@injectable
class AuthFormCubit extends Cubit<AuthFormState> {
  AuthFormCubit(this._auth, this._profile, this._balance)
    : super(const AuthFormState());

  final AuthRepository _auth;
  final ProfileCubit _profile;
  final BalanceRepository _balance;

  void togglePasswordVisibility() =>
      emit(state.copyWith(passwordHidden: !state.passwordHidden));
  void toggleConfirmPasswordVisibility() =>
      emit(state.copyWith(confirmPasswordHidden: !state.confirmPasswordHidden));
  void toggleTerms(bool? accepted) =>
      emit(state.copyWith(termsAccepted: accepted ?? false));

  Future<Failure?> login(String email, String password) => _submit(
    () async {
      await _profile.clearUserData();
      return _auth.signIn(email.trim(), password.trim());
    },
    title: 'Login Failed',
    message: 'Email or Password incorrect!',
    verifyProfile: true,
  );

  Future<Failure?> register(
    String email,
    String password,
    String username,
    String confirmPassword,
  ) async {
    if (password.trim() != confirmPassword.trim()) {
      return const Failure('Passwords do not match');
    }
    if (!state.termsAccepted) {
      return const Failure('Please accept the terms and conditions');
    }
    return _submit(
      () => _auth.register(email.trim(), password.trim(), username.trim()),
      title: 'Register Failed',
      message: 'Failed to register',
    );
  }

  Future<Failure?> google() => _submit(
    _auth.signInWithGoogle,
    title: 'Google Sign-In Failed',
    message: 'Google sign-in failed',
  );

  Future<Failure?> anonymous({required bool registering}) => _submit(
    _auth.signInAnonymously,
    title: 'Anonymous Sign-In Failed',
    message: 'Anonymous sign-in failed',
    updateFinancials: registering,
  );

  Future<Failure?> _submit(
    Future<bool> Function() authenticate, {
    required String title,
    required String message,
    bool verifyProfile = false,
    bool updateFinancials = true,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      if (!await authenticate()) return Failure(message, title: title);
      await _profile.loadUserData(forceRefresh: true);
      if (verifyProfile && _profile.state.user == null) {
        return const Failure('Failed to load user data');
      }
      if (updateFinancials) await _balance.updateUserFinancials();
      return null;
    } catch (error) {
      final failure = ErrorHandler.from(error);
      if (failure.code == 'email-not-verified') {
        return Failure(
          failure.message,
          title: 'Email Not Verified',
          warning: true,
        );
      }
      return Failure(failure.message, title: title, code: failure.code);
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }
}
