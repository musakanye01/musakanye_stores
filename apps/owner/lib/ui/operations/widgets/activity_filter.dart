import 'package:shared_core/domain/model/sale_history.dart';

/// Chips shown above the recent activity list.
enum ActivityFilter {
  allSales('All sales'),
  cashSales('Cash sales'),
  ecocashSales('Ecocash sales'),
  shifts('Shifts');

  const ActivityFilter(this.label);
  final String label;

  /// True for the three sales chips, false for the shifts chip.
  bool get showsSales => this != ActivityFilter.shifts;

  /// Only completed sales are listed. Payment method is compared loosely
  /// ("Cash", "cash", "EcoCash", "eco_cash" all match) so the exact stored
  /// casing does not matter.
  bool matchesSale(SaleHistory sale) {
    if (sale.status.toLowerCase() != 'completed') return false;

    final method = normalisePaymentMethod(sale.paymentMethod);
    switch (this) {
      case ActivityFilter.allSales:
        return true;
      case ActivityFilter.cashSales:
        return method == 'cash';
      case ActivityFilter.ecocashSales:
        return method == 'ecocash';
      case ActivityFilter.shifts:
        return false;
    }
  }
}

String normalisePaymentMethod(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
