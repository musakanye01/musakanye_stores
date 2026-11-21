import 'package:shared_core/domain/model/catalogue_item.dart';

class SalesTrendPoint {
  const SalesTrendPoint({required this.day, required this.amountCents});

  /// Short display label, e.g. Mon.
  final String day;
  final int amountCents;

  factory SalesTrendPoint.fromJson(Map<String, dynamic> json) {
    return SalesTrendPoint(
      day: json['day'] as String,
      amountCents: (json['amount_cents'] as num).toInt(),
    );
  }
}

class FastMovingProduct {
  const FastMovingProduct({required this.name, required this.unitsSold});

  final String name;
  final int unitsSold;

  factory FastMovingProduct.fromJson(Map<String, dynamic> json) {
    return FastMovingProduct(
      name: json['name'] as String,
      unitsSold: (json['units_sold'] as num).toInt(),
    );
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.todayCents,
    required this.weekCents,
    required this.todayTransactionCount,
    required this.averageSpendCents,
    required this.openShiftCount,
    required this.salesTrend,
    required this.fastMovingProducts,
    required this.lowStockCount,
    required this.lowStockItems,
  });

  final int todayCents;
  final int weekCents;
  final int todayTransactionCount;
  final int averageSpendCents;
  final int openShiftCount;
  final List<SalesTrendPoint> salesTrend;
  final List<FastMovingProduct> fastMovingProducts;
  final int lowStockCount;
  final List<CatalogueItem> lowStockItems;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      todayCents: (json['today_cents'] as num).toInt(),
      weekCents: (json['week_cents'] as num).toInt(),
      todayTransactionCount: (json['today_transaction_count'] as num).toInt(),
      averageSpendCents: (json['average_spend_cents'] as num).toInt(),
      openShiftCount: (json['open_shift_count'] as num).toInt(),
      salesTrend: (json['sales_trend'] as List<dynamic>? ?? const [])
          .map((e) => SalesTrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      fastMovingProducts:
          (json['fast_moving_products'] as List<dynamic>? ?? const [])
              .map((e) => FastMovingProduct.fromJson(e as Map<String, dynamic>))
              .toList(),
      lowStockCount: (json['low_stock_count'] as num).toInt(),
      lowStockItems: (json['low_stock_items'] as List<dynamic>? ?? const [])
          .map((e) => CatalogueItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
