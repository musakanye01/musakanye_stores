import 'package:shared_core/domain/model/sale_history.dart';

enum ActivityFilter {
  allSales('All sales'),
  cashSales('Cash'),
  ecocashSales('EcoCash');

  const ActivityFilter(this.label);

  final String label;

  bool matchesSale(SaleHistory sale) {
    final method = normalisePaymentMethod(sale.paymentMethod);

    switch (this) {
      case ActivityFilter.allSales:
        return true;
      case ActivityFilter.cashSales:
        return method == 'cash';
      case ActivityFilter.ecocashSales:
        return method == 'ecocash';
    }
  }
}

String normalisePaymentMethod(String value) {
  final normalised = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

  switch (normalised) {
    case 'cash':
      return 'cash';
    case 'ecocash':
    case 'ecocashusd':
      return 'ecocash';
    default:
      return normalised;
  }
}
