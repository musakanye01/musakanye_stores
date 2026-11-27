enum SalesPeriod {
  today(dayCount: 1, trendLabel: 'Hourly sales'),
  last7Days(dayCount: 7, trendLabel: 'Daily sales · Last 7 days'),
  last30Days(dayCount: 30, trendLabel: 'Daily sales · Last 30 days');

  const SalesPeriod({required this.dayCount, required this.trendLabel});

  final int dayCount;
  final String trendLabel;

  /// Local midnight of the first day in the period.
  ///
  /// Uses calendar arithmetic, so daylight saving changes cannot shift it.
  DateTime start(DateTime now) =>
      DateTime(now.year, now.month, now.day - (dayCount - 1));
}
