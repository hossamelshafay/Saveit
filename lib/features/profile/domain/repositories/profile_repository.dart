import 'dart:typed_data';

import 'package:saveit/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> load();
  Future<void> update(Map<String, dynamic> data);
  Future<void> createOrUpdateUser(String username);
  Future<String> uploadPhoto(Uint8List image);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount(String password);
}
