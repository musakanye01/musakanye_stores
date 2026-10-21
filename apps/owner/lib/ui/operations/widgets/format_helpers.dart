String formatCents(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

String capitalise(String value) => value.isEmpty
    ? value
    : value[0].toUpperCase() + value.substring(1).toLowerCase();

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

/// "Today, 10:42 AM", "Yesterday, 2:05 PM" or "14 Oct, 11:10 AM".
String formatActivityDate(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final daysAgo = today.difference(day).inDays;

  final time = formatTime(local);
  if (daysAgo == 0) return 'Today, $time';
  if (daysAgo == 1) return 'Yesterday, $time';
  return '${local.day} ${_months[local.month - 1]}, $time';
}
