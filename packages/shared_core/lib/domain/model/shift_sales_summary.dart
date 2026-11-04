class ShiftSalesSummary {
  final int salesCount;
  final int cashSalesCents;
  final int ecoCashSalesCents;

  const ShiftSalesSummary({
    required this.salesCount,
    required this.cashSalesCents,
    required this.ecoCashSalesCents,
  });

  const ShiftSalesSummary.empty()
    : salesCount = 0,
      cashSalesCents = 0,
      ecoCashSalesCents = 0;

  int get totalSalesCents => cashSalesCents + ecoCashSalesCents;
}
