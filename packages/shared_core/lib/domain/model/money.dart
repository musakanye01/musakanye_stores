/// Money stored as integer cents.
///
/// The POS MVP supports USD only. Keeping amounts as integer cents avoids
/// floating-point rounding errors.
class Money {
  const Money._(this.cents);

  final int cents;

  factory Money.fromCents(int cents) {
    if (cents < 0) {
      throw ArgumentError.value(cents, 'cents', 'Money cannot be negative.');
    }

    return Money._(cents);
  }

  factory Money.zero() => const Money._(0);

  bool get isZero => cents == 0;

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => 'USD ${(cents / 100).toStringAsFixed(2)}';
}
