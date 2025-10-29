import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';

class UserService {
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

  Future<UserModel?> getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final docSnap = await _firestore.collection('users').doc(user.uid).get();
    if (!docSnap.exists) return null;

    return UserModel.fromMap(docSnap.data()!);
  }
}
