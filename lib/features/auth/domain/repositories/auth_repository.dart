typedef AuthSession = ({String id, bool isAnonymous});

abstract interface class AuthRepository {
  AuthSession? get session;
  Stream<AuthSession?> get sessionChanges;
  Future<bool> signIn(String email, String password);
  Future<bool> register(String email, String password, String username);
  Future<bool> signInWithGoogle();
  Future<bool> signInWithFacebook();
  Future<bool> signInAnonymously();
  Future<void> resetPassword(String email);
  Future<void> signOut();
}
