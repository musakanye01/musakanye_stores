import 'package:owner/ui/operations/sales_period.dart';
import 'package:owner/ui/operations/sales_trend_chart.dart';
import 'package:owner/ui/operations/widgets/activity_filter.dart';
import 'package:shared_core/domain/model/sale_history.dart';

/// Sales within the period, newest first.
List<SaleHistory> salesForPeriod(
  List<SaleHistory> allSales,
  SalesPeriod period,
  DateTime now,
) {
  final start = period.start(now);
  // End of today rather than `now`, so a sale stamped slightly ahead of this
  // device's clock is not hidden.
  final end = DateTime(now.year, now.month, now.day + 1);

  return allSales.where((sale) {
    final date = sale.createdAt.toLocal();
    return !date.isBefore(start) && date.isBefore(end);
  }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

List<SaleHistory> visibleSales(
  List<SaleHistory> periodSales,
  ActivityFilter filter,
  String searchQuery,
) {
  final query = searchQuery.trim().toLowerCase();

  return periodSales.where((sale) {
    if (!filter.matchesSale(sale)) return false;
    if (query.isEmpty) return true;

    return sale.id.toLowerCase().contains(query) ||
        sale.paymentMethod.toLowerCase().contains(query);
  }).toList();
}

List<SaleHistory> completedSales(List<SaleHistory> sales) {
  return sales
      .where((sale) => sale.status.toLowerCase() == 'completed')
      .toList();
}

int totalSalesCents(List<SaleHistory> sales) {
  return sales.fold(0, (total, sale) => total + sale.totalCents);
}

List<SalesTrendPoint> buildTrendPoints(
  List<SaleHistory> sales,
  SalesPeriod period,
  DateTime now,
) {
  return period == SalesPeriod.today
      ? _hourlyPoints(sales)
      : _dailyPoints(sales, period, now);
}

List<SalesTrendPoint> _hourlyPoints(List<SaleHistory> sales) {
  const labels = {0: '12 AM', 6: '6 AM', 12: '12 PM', 18: '6 PM', 23: '11 PM'};
  final totals = List<int>.filled(24, 0);

  for (final sale in sales) {
    totals[sale.createdAt.toLocal().hour] += sale.totalCents;
  }

  return List.generate(
    24,
    (hour) =>
        SalesTrendPoint(label: labels[hour] ?? '', valueCents: totals[hour]),
  );
}

List<SalesTrendPoint> _dailyPoints(
  List<SaleHistory> sales,
  SalesPeriod period,
  DateTime now,
) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final dayCount = period.dayCount;
  final firstDay = period.start(now);
  // Compare dates in UTC: a local 23-hour day would otherwise count as 0 days.
  final firstDayUtc = DateTime.utc(firstDay.year, firstDay.month, firstDay.day);
  final totals = List<int>.filled(dayCount, 0);

  for (final sale in sales) {
    final date = sale.createdAt.toLocal();
    final index = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(firstDayUtc).inDays;

    if (index >= 0 && index < dayCount) {
      totals[index] += sale.totalCents;
    }
  }

  return List.generate(dayCount, (index) {
    final day = DateTime(firstDay.year, firstDay.month, firstDay.day + index);

    final label = dayCount == 7
        ? weekdays[day.weekday - 1]
        : (index % 5 == 0 || index == dayCount - 1)
        ? '${day.day}'
        : '';

    return SalesTrendPoint(label: label, valueCents: totals[index]);
  });
}
