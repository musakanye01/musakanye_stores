import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncFailure implements Exception {
  const SyncFailure(this.message, {required this.retryable});

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}

/// Turns any thrown error into a SyncFailure.
/// Retryable = might succeed later without changing the data.
SyncFailure classifySyncError(Object error) {
  if (error is SyncFailure) return error;

  if (error is SocketException ||
      error is TimeoutException ||
      error is http.ClientException ||
      error is AuthRetryableFetchException) {
    return SyncFailure('Network error: $error', retryable: true);
  }

  if (error is AuthException) {
    // Token problem; ensureValidSession() decides on the next attempt.
    return SyncFailure(error.message, retryable: true);
  }

  if (error is PostgrestException) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();
    final status = int.tryParse(code);

    final jwtExpired = code == 'PGRST301' || message.contains('jwt expired');
    final serverDown = status != null && status >= 500 && status < 600;
    // Postgres classes 08 (connection), 53 (resources), 57 (shutdown).
    final transientPg =
        code.startsWith('08') || code.startsWith('53') || code.startsWith('57');

    if (jwtExpired || serverDown || transientPg) {
      return SyncFailure(error.message, retryable: true);
    }
    return SyncFailure(error.message, retryable: false);
  }

  return SyncFailure(
    error.toString().replaceFirst('Exception: ', ''),
    retryable: false,
  );
}
