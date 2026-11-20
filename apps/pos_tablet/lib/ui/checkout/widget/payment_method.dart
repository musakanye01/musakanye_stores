import 'package:flutter/material.dart';

/// Payment methods offered at checkout.
///
/// [apiValue] is the exact string the checkout input already used
/// ('cash' / 'ecocash_usd'), so nothing downstream changes.
enum PaymentMethod {
  cash('cash', 'Cash', Icons.payments_outlined),
  ecocashUsd('ecocash_usd', 'EcoCash (USD)', Icons.phone_android_outlined);

  const PaymentMethod(this.apiValue, this.label, this.icon);

  final String apiValue;
  final String label;
  final IconData icon;
}
