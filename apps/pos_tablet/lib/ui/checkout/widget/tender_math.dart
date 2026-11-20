import 'package:pos_tablet/ui/checkout/widget/payment_method.dart';

/// Pure helpers for the amount received / change / completion rules.
/// Shared by the screen (to validate on submit) and the payment card (to
/// render), so both always agree.

/// Parses the amount field into cents. Returns null when empty, invalid,
/// negative, or has more than two decimal places.
int? parseCents(String text) {
  final amount = double.tryParse(text.trim());
  if (amount == null || !amount.isFinite || amount < 0) return null;
  final cents = (amount * 100).round();
  if ((amount * 100 - cents).abs() > 0.000001) return null;
  return cents;
}

int changeCents({required int? receivedCents, required int totalCents}) {
  final received = receivedCents ?? 0;
  return received > totalCents ? received - totalCents : 0;
}

bool canCompleteSale({
  required bool hasItems,
  required PaymentMethod method,
  required int? receivedCents,
  required int totalCents,
}) {
  if (!hasItems) return false;
  if (method != PaymentMethod.cash) return true;
  return receivedCents != null && receivedCents >= totalCents;
}

/// Quick-cash suggestions: the exact total plus the next round figures
/// above it ($5 / $10 / $50 / $100 steps), at most five.
List<int> quickAmountsCents(int totalCents) {
  if (totalCents <= 0) return const [];

  final amounts = <int>{totalCents};
  for (final step in const [500, 1000, 5000, 10000]) {
    amounts.add(((totalCents + step - 1) ~/ step) * step);
  }
  return (amounts.toList()..sort()).take(5).toList();
}
