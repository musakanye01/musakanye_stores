import 'dart:async';

import 'package:shared_core/data/auth_service.dart';
import 'package:shared_core/domain/model/app_user.dart';
import 'package:shared_core/util/result.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> login(String username, String password);
  Future<Result<void>> logout();
  Future<Result<AppUser?>> restoreSession();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({required this._authService});

  @override
  Future<Result<AppUser>> login(String username, String password) async {
    final result = await _authService.login(username, password);

    return result;
  }

  @override
  Future<Result<void>> logout() async {
    final result = await _authService.logout();
    return result;
  }

  @override
  Future<Result<AppUser?>> restoreSession() async {
    return await _authService.restoreSession();
  }
}
