import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saveit/features/profile/domain/entities/user_profile.dart';
import 'package:saveit/features/profile/domain/repositories/profile_repository.dart';
import 'package:saveit/core/errors/error_handler.dart';

class ProfileState {
  const ProfileState({this.user, this.isLoading = false, this.error});

  final UserProfile? user;
  final bool isLoading;
  final String? error;
}

@lazySingleton
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;
  DateTime? _lastLoadTime;
  int _request = 0;

  Future<void> loadUserData({bool forceRefresh = false}) async {
    final lastLoad = _lastLoadTime;
    if (!forceRefresh &&
        state.user != null &&
        lastLoad != null &&
        DateTime.now().difference(lastLoad) < const Duration(minutes: 5)) {
      return;
    }

    final request = ++_request;
    emit(ProfileState(user: state.user, isLoading: true));
    try {
      final user = await _repository.load();
      if (isClosed || request != _request) return;
      _lastLoadTime = DateTime.now();
      emit(ProfileState(user: user));
    } catch (error) {
      if (!isClosed && request == _request) {
        emit(ProfileState(error: ErrorHandler.from(error).message));
      }
    }
  }

  Future<void> updateField(String field, String value) async {
    await _repository.update({field: value});
    if (field == 'username') await _repository.createOrUpdateUser(value);
    await loadUserData(forceRefresh: true);
  }

  Future<void> updatePhoto(Uint8List image) async {
    final photo = await _repository.uploadPhoto(image);
    await _repository.update({'photoUrl': photo});
    await loadUserData(forceRefresh: true);
  }

  Future<void> clearUserData() async {
    final user = state.user;
    _request++;
    _lastLoadTime = null;
    emit(const ProfileState());
    if (user != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastUsername', user.username);
        await prefs.setString('lastEmail', user.email);
      } catch (_) {
        // Local history is optional during sign-in.
      }
    }
  }
}
