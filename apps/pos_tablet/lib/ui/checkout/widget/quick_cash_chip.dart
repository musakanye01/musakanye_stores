import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/checkout/widget/tender_math.dart';
import 'package:pos_tablet/ui/shared/money.dart';

/// Tap-to-fill amounts for cash payments: "Exact" plus round figures above
/// the total. The chip matching [receivedCents] shows as selected.
class QuickCashChips extends StatelessWidget {
  const QuickCashChips({
    super.key,
    required this.totalCents,
    required this.receivedCents,
    required this.enabled,
    required this.onSelected,
  });

  final int totalCents;
  final int? receivedCents;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final amounts = quickAmountsCents(totalCents);
    if (amounts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final cents in amounts)
          ChoiceChip(
            label: Text(cents == totalCents ? 'Exact' : formatUsd(cents)),
            selected: receivedCents == cents,
            onSelected: enabled ? (_) => onSelected(cents) : null,
          ),
      ],
    );
  }
}
