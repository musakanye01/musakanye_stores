String formatDateTime(DateTime value) {
  final d = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

String paymentMethodLabel(String method) {
  switch (method) {
    case 'cash':
      return 'Cash';
    case 'ecocash_usd':
      return 'EcoCash (USD)';
    case 'bank_transfer_usd':
      return 'Bank transfer (USD)';
    default:
      return method;
  }
}
