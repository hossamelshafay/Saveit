import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';
import 'package:saveit/features/auth/data/data_sources/firebase_auth_source.dart';

@LazySingleton(as: AuthRepository)
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._source);

  final FirebaseAuthSource _source;

  AuthSession? _session(User? user) =>
      user == null ? null : (id: user.uid, isAnonymous: user.isAnonymous);

  @override
  AuthSession? get session => _session(_source.currentUser);

  @override
  Stream<AuthSession?> get sessionChanges =>
      _source.authStateChanges.map(_session);

  @override
  Future<bool> signIn(String email, String password) async =>
      (await _source.signInWithEmailAndPassword(email, password))?.user != null;

  @override
  Future<bool> register(String email, String password, String username) async =>
      (await _source.registerWithEmailAndPassword(
        email,
        password,
        username,
      ))?.user !=
      null;

  @override
  Future<bool> signInWithGoogle() async =>
      await _source.signInWithGoogle() != null;

  @override
  Future<bool> signInWithFacebook() async =>
      await _source.signInWithFacebook() != null;

  @override
  Future<bool> signInAnonymously() async =>
      await _source.signInAnonymously() != null;

  @override
  Future<void> resetPassword(String email) => _source.resetPassword(email);

  @override
  Future<void> signOut() => _source.signOut();
}
