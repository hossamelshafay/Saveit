import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';
import 'package:saveit/features/profile/domain/repositories/profile_repository.dart';
import 'package:saveit/core/errors/failures.dart';
import 'package:saveit/core/errors/error_handler.dart';

@injectable
class AccountCubit extends Cubit<bool> {
  AccountCubit(this._auth, this._profile) : super(false);

  final AuthRepository _auth;
  final ProfileRepository _profile;

  Future<Failure?> resetPassword(String email) =>
      _run(() => _auth.resetPassword(email));
  Future<Failure?> changePassword(String currentPassword, String newPassword) =>
      _run(() => _profile.changePassword(currentPassword, newPassword));
  Future<Failure?> deleteAccount(String password) =>
      _run(() => _profile.deleteAccount(password));
  Future<Failure?> logout() => _run(_auth.signOut);

  Future<Failure?> _run(Future<void> Function() operation) async {
    emit(true);
    try {
      await operation();
      return null;
    } catch (error) {
      return ErrorHandler.from(error);
    } finally {
      if (!isClosed) emit(false);
    }
  }
}
