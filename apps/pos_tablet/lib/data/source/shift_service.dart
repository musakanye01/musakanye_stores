import 'package:supabase_flutter/supabase_flutter.dart';

class ShiftService {
  final SupabaseClient _client;
  ShiftService(this._client);

  /// Authenticated user used to associate locally stored shifts.
  String? get currentUserId => _client.auth.currentUser?.id;
}
