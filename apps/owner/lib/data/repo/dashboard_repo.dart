import 'package:owner/data/source/dashboard_service.dart';
import 'package:shared_core/util/result.dart';
import 'package:shared_core/domain/model/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<Result<DashboardSummary>> getSummary();
}

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required this._dashboardService});

  final DashboardService _dashboardService;

  /// A variant at or below this quantity is flagged as low stock.
  static const int lowStockThreshold = 5;

  /// How many low-stock items the dashboard lists.
  static const int lowStockLimit = 5;

  /// Harare is UTC+2 all year (no daylight saving).
  static const Duration _harareOffset = Duration(hours: 2);

  /// Midnight today in Harare, as an absolute (UTC) instant.
  static DateTime startOfTodayHarare() {
    final harareNow = DateTime.now().toUtc().add(_harareOffset);
    final harareMidnight = DateTime.utc(
      harareNow.year,
      harareNow.month,
      harareNow.day,
    );
    return harareMidnight.subtract(_harareOffset);
  }

  @override
  Future<Result<DashboardSummary>> getSummary() {
    return _dashboardService.fetchSummary(
      dayStart: startOfTodayHarare(),
      lowStockThreshold: lowStockThreshold,
      lowStockLimit: lowStockLimit,
    );
  }
}
