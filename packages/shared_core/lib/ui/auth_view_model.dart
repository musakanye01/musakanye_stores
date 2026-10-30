import 'package:flutter/material.dart';
import 'package:shared_core/data/auth_repo.dart';
import 'package:shared_core/domain/model/app_user.dart';
import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';

import 'dart:async';

enum AuthStatus { uninitialized, unauthenticated, authenticated }

class LoginCredentials {
  final String username;
  final String password;
  const LoginCredentials({required this.username, required this.password});
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  late final Command1<void, LoginCredentials> login;
  late final Command0<void> logout;

  AuthViewModel(this._authRepository) {
    login = Command1(_handleLogin);
    logout = Command0(_handleLogout);
    unawaited(_restoreSession());
  }

  Future<void> _restoreSession() async {
    try {
      final result = await _authRepository.restoreSession();

      switch (result) {
        case Ok<AppUser?>(value: final user):
          _setUser(user);

        case Error<AppUser?>():
          _setUser(null);
      }
    } catch (e) {
      debugPrint('Session restoration failed: $e');
      _setUser(null);
    }
  }

  void _setUser(AppUser? user) {
    _currentUser = user;
    _status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners(); // triggers GoRouter's refreshListenable
  }

  Future<Result<void>> _handleLogin(LoginCredentials credentials) async {
    final result = await _authRepository.login(
      credentials.username,
      credentials.password,
    );
    switch (result) {
      case Ok<AppUser>(value: final user):
        _setUser(user);
        return const Result.ok(null);
      case Error<AppUser>(error: final err):
        return Result.error(err);
    }
  }

  Future<Result<void>> _handleLogout() async {
    final result = await _authRepository.logout();
    if (result is Ok) _setUser(null);
    return result;
  }
}
