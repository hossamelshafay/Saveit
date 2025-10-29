import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class UserProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastLoadTime;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cache duration of 5 minutes
  static const cacheDuration = Duration(minutes: 5);

  Future<void> loadUserData({bool forceRefresh = false}) async {
    try {
      // Clear error state
      _error = null;
      _isLoading = true;
      notifyListeners();

      // Check cache validity
      if (!forceRefresh &&
          _currentUser != null &&
          _lastLoadTime != null &&
          DateTime.now().difference(_lastLoadTime!) < cacheDuration) {
        return;
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      Map<String, dynamic> userData;
      if (!docSnapshot.exists) {
        // Create a default user document if it doesn't exist
        userData = {
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
        _currentUser = UserModel.fromMap(newDocSnapshot.data()!);
      } else {
        _currentUser = UserModel.fromMap(docSnapshot.data()!);
      }
      _lastLoadTime = DateTime.now();
    } catch (e) {
      _currentUser = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      await _firestore.collection('users').doc(user.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadUserData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearUserData() async {
    try {
      // Store the current user data in SharedPreferences before clearing
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastUsername', _currentUser!.username);
        await prefs.setString('lastEmail', _currentUser!.email);
      }
    } catch (e) {
      print('Error saving last user data: $e');
    }

    _currentUser = null;
    _error = null;
    _lastLoadTime = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> getLastUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('lastUsername');
    } catch (e) {
      print('Error getting last username: $e');
      return null;
    }
  }
}
