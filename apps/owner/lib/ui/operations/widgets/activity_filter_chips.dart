import 'package:flutter/material.dart';
import 'package:owner/ui/operations/widgets/activity_filter.dart';
import 'package:owner/ui/operations/widgets/operations_colors.dart';

class ActivityFilterChips extends StatelessWidget {
  const ActivityFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ActivityFilter selected;
  final ValueChanged<ActivityFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in ActivityFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: filter == selected,
                showCheckmark: false,
                selectedColor: OperationsColors.selectedChip,
                labelStyle: TextStyle(
                  color: filter == selected
                      ? OperationsColors.primary
                      : OperationsColors.muted,
                  fontWeight: filter == selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}
