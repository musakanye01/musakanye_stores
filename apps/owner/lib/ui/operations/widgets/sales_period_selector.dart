import 'package:flutter/material.dart';
import 'package:owner/ui/operations/sales_period.dart';

class SalesPeriodSelector extends StatelessWidget {
  const SalesPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final SalesPeriod selected;
  final ValueChanged<SalesPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<SalesPeriod>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: SalesPeriod.today, label: Text('Today')),
          ButtonSegment(value: SalesPeriod.last7Days, label: Text('7 days')),
          ButtonSegment(value: SalesPeriod.last30Days, label: Text('30 days')),
        ],
        selected: {selected},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}
