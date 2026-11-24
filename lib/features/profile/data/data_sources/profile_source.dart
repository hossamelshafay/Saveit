import 'package:injectable/injectable.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:saveit/features/profile/domain/entities/user_profile.dart';
import 'package:saveit/core/errors/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saveit/features/profile/data/models/user_model.dart';

@lazySingleton
class ProfileSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createOrUpdateUser(String username) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnap = await docRef.get();

    // Update profile display name in Firebase Auth
    await user.updateDisplayName(username);

    final userData = {
      'uid': user.uid,
      'email': user.email ?? 'Anonymous',
      'username': username,
      'previousName': docSnap.exists
          ? (docSnap.data()?['username'] as String?)
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!docSnap.exists) {
      // If document doesn't exist, create it with all default values
      await docRef.set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'currency': 'SAR',
        'balance': 0.0,
        'income': 0.0,
        'expenses': 0.0,
        'savings': 0.0,
        'totalInstallments': 0.0,
        'paidInstallments': 0.0,
        'photoUrl': user.photoURL,
      });
    } else {
      // If document exists, only update the specified fields
      await docRef.update(userData);
    }
  }

  Future<UserProfile> load() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final docSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!docSnapshot.exists) {
      // Create a default user document if it doesn't exist
      final userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'username': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'currency': 'SAR',
        'balance': 0.0,
        'income': 0.0,
        'expenses': 0.0,
        'savings': 0.0,
        'totalInstallments': 0.0,
        'paidInstallments': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'photoUrl': user.photoURL,
        'authProvider': user.providerData.isNotEmpty
            ? user.providerData[0].providerId
            : 'email',
      };

      // Create the document with merge to preserve any existing data
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      // Load the newly created document to ensure we have server timestamps
      final newDocSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      return decodeUserProfile(newDocSnapshot.data()!);
    }
    return decodeUserProfile(docSnapshot.data()!);
  }

  Future<void> update(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw const ServiceException('No user signed in');
    await _firestore.collection('users').doc(user.uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Reference _photo(String uid) =>
      FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');

  Future<String> uploadPhoto(Uint8List image) async {
    final user = _auth.currentUser;
    if (user == null) throw const ServiceException('No user signed in');
    final reference = _photo(user.uid);
    await reference.putData(image);
    return reference.getDownloadURL();
  }

  Future<User> _reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw const ServiceException('No user logged in');
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    return user;
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = await _reauthenticate(currentPassword);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount(String password) async {
    final user = await _reauthenticate(password);
    await _firestore.collection('users').doc(user.uid).delete();
    try {
      await _photo(user.uid).delete();
    } catch (error) {
      debugPrint('Unable to remove the profile photo: $error');
    }
    await user.delete();
  }
}
