class ShiftSalesSummary {
  final int cashSalesCents;
  final int ecoCashSalesCents;

  const ShiftSalesSummary({
    required this.cashSalesCents,
    required this.ecoCashSalesCents,
  });

  const ShiftSalesSummary.empty()
      : cashSalesCents = 0,
        ecoCashSalesCents = 0;
}