import 'package:shared_core/domain/model/app_user.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService(this._client);
  final SupabaseClient _client;

  Future<Result<AppUser>> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        return Result.ok(AppUser(id: user.id, email: user.email));
      }
      return Result.error(Exception("Something unexpected happened"));
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('invalid login credentials')) {
        return Result.error(Exception('Email or password is incorrect.'));
      }

      if (message.contains('email not confirmed')) {
        return Result.error(Exception('Confirm your email before signing in.'));
      }

      return Result.error(
        Exception('Authentication failed. Check your details and try again.'),
      );
    } catch (_) {
      return Result.error(
        Exception('Unable to sign in. Check your connection and try again.'),
      );
    }
  }

  Future<Result<void>> logout() async {
    try {
      await _client.auth.signOut();
      return const Result.ok(null);
    } on AuthException catch (_) {
      return Result.error(Exception('Unable to sign out. Please try again.'));
    } catch (_) {
      return Result.error(Exception('Unable to sign out. Please try again.'));
    }
  }
}
