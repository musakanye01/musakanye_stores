class Shift {
  final String id;
  final String cashierId;
  final String? deviceId;
  final int openingFloatCents;
  final String status;
  final DateTime openedAt;

  const Shift({
    required this.id,
    required this.cashierId,
    required this.deviceId,
    required this.openingFloatCents,
    required this.status,
    required this.openedAt,
  });

  double get openingFloat => openingFloatCents / 100;

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
        id: json['id'] as String,
        cashierId: json['cashier_id'] as String,
        deviceId: json['device_id'] as String?,
        openingFloatCents: (json['opening_float_cents'] as num).toInt(),
        status: json['status'] as String,
        openedAt: DateTime.parse(json['opened_at'] as String),
      );
}