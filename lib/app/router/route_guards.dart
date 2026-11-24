import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';
import 'package:saveit/app/router/route_names.dart';

class RouteGuards extends ChangeNotifier {
  RouteGuards(this._auth) {
    _subscription = _auth.sessionChanges.listen((_) => notifyListeners());
  }

  final AuthRepository _auth;
  late final StreamSubscription<AuthSession?> _subscription;

  bool get isSignedIn => _auth.session != null;

  String get afterSplash => isSignedIn ? RouteNames.home : RouteNames.login;

  String? redirect(String path) {
    if (path == '/') return RouteNames.splash;
    if (path == RouteNames.splash ||
        path == RouteNames.login ||
        path == RouteNames.register ||
        path == RouteNames.forgotPassword) {
      return null;
    }
    return isSignedIn ? null : RouteNames.login;
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
