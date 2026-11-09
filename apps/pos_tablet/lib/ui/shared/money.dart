/// Formats integer cents as dollars. Integer math only, no doubles.
String formatUsd(int cents) {
  final sign = cents < 0 ? '-' : '';
  final abs = cents.abs();
  return '$sign\$${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
}

/// Parses a typed dollar amount into integer cents without using doubles.
/// Accepts "12", "12.5", "12.50". Rejects blanks, negatives, 3+ decimals,
/// separators, and anything over 10 digits of dollars. Strict on purpose,
/// since this is cash handling.
int? parseUsdToCents(String input) {
  final match = RegExp(r'^(\d{1,10})(?:\.(\d{1,2}))?$')
      .firstMatch(input.trim());
  if (match == null) return null;

  final dollars = int.parse(match.group(1)!);
  final decimals = match.group(2);
  final cents = decimals == null ? 0 : int.parse(decimals.padRight(2, '0'));
  return dollars * 100 + cents;
}
