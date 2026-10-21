import 'package:shared_core/domain/model/catalogue_item.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.allTimeCents,
    required this.todayCents,
    required this.lowStockCount,
    required this.lowStockItems,
  });

  final int allTimeCents;
  final int todayCents;

  /// Total number of variants at or below the low-stock threshold.
  final int lowStockCount;

  /// The lowest-stock variants, limited to the dashboard list size.
  final List<CatalogueItem> lowStockItems;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final items = (json['low_stock_items'] as List<dynamic>? ?? const [])
        .map((e) => CatalogueItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return DashboardSummary(
      allTimeCents: (json['all_time_cents'] as num).toInt(),
      todayCents: (json['today_cents'] as num).toInt(),
      lowStockCount: (json['low_stock_count'] as num).toInt(),
      lowStockItems: items,
    );
  }
}
