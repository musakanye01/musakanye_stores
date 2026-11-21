import 'package:owner/data/source/dashboard_service.dart';
import 'package:shared_core/domain/model/dashboard_summary.dart';
import 'package:shared_core/util/result.dart';

abstract class DashboardRepository {
  Future<Result<DashboardSummary>> getSummary();
}

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required this._dashboardService});

  final DashboardService _dashboardService;

  static const int lowStockThreshold = 5;
  static const int lowStockLimit = 5;

  static const Duration _harareOffset = Duration(hours: 2);

  static DateTime _harareMidnight(DateTime date) {
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).subtract(_harareOffset);
  }

  static DateTime _harareNow() {
    return DateTime.now().toUtc().add(_harareOffset);
  }

  @override
  Future<Result<DashboardSummary>> getSummary() {
    final now = _harareNow();

    final today = DateTime.utc(now.year, now.month, now.day);
    final todayStart = _harareMidnight(today);

    final monday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    final weekStart = _harareMidnight(monday);

    final sevenDayStart = _harareMidnight(
      today.subtract(const Duration(days: 6)),
    );

    return _dashboardService.fetchSummary(
      dayStart: todayStart,
      weekStart: weekStart,
      sevenDayStart: sevenDayStart,
      lowStockThreshold: lowStockThreshold,
      lowStockLimit: lowStockLimit,
    );
  }
}
