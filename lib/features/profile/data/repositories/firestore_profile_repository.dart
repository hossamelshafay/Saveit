import 'package:injectable/injectable.dart';
import 'package:saveit/features/profile/domain/repositories/profile_repository.dart';
import 'package:saveit/features/profile/data/data_sources/profile_source.dart';

import 'dart:typed_data';

import 'package:saveit/features/profile/domain/entities/user_profile.dart';

@LazySingleton(as: ProfileRepository)
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._source);

  final ProfileSource _source;

  @override
  Future<UserProfile> load() => _source.load();

  @override
  Future<void> update(Map<String, dynamic> data) => _source.update(data);

  @override
  Future<void> createOrUpdateUser(String username) =>
      _source.createOrUpdateUser(username);

  @override
  Future<String> uploadPhoto(Uint8List image) => _source.uploadPhoto(image);

  @override
  Future<void> changePassword(String currentPassword, String newPassword) =>
      _source.changePassword(currentPassword, newPassword);

  @override
  Future<void> deleteAccount(String password) =>
      _source.deleteAccount(password);
}
