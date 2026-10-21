import 'package:flutter/foundation.dart';
import 'package:shared_core/domain/model/dashboard_summary.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  DashboardService(this._client);
  final SupabaseClient _client;

  Future<Result<DashboardSummary>> fetchSummary({
    required DateTime dayStart,
    required int lowStockThreshold,
    required int lowStockLimit,
  }) async {
    try {
      final response = await _client.rpc(
        'dashboard_summary',
        params: {
          'day_start': dayStart.toUtc().toIso8601String(),
          'low_stock_threshold': lowStockThreshold,
          'low_stock_limit': lowStockLimit,
        },
      );
      return Result.ok(
        DashboardSummary.fromJson(response as Map<String, dynamic>),
      );
    } on PostgrestException catch (e, s) {
      debugPrint('dashboard_summary failed: ${e.message}\n$s');
      return Result.error(
        Exception('Unable to load dashboard data. Please try again.'),
      );
    } catch (e, s) {
      debugPrint('dashboard_summary failed: $e\n$s');
      return Result.error(
        Exception('Unable to load dashboard data. Check your connection.'),
      );
    }
  }
}
