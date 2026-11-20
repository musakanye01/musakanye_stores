import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/checkout/widget/payment_method.dart';

/// Full-width segmented control for choosing the payment method.
/// Pass a null [onChanged] to disable it (for example while processing).
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<PaymentMethod>(
        showSelectedIcon: false,
        segments: [
          for (final method in PaymentMethod.values)
            ButtonSegment<PaymentMethod>(
              value: method,
              label: Text(method.label),
              icon: Icon(method.icon),
            ),
        ],
        selected: {selected},
        onSelectionChanged: onChanged == null
            ? null
            : (selection) => onChanged!(selection.first),
      ),
    );
  }
}
