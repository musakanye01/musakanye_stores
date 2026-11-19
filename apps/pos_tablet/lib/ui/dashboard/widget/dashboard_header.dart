import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.shiftState});

  final ShiftState shiftState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final (statusLabel, statusColor, statusIcon) = switch (shiftState) {
      ShiftState.open => (
        'Shift active',
        const Color(0xFF16834A),
        Icons.check_circle_outline,
      ),
      ShiftState.none => (
        'No active shift',
        colors.error,
        Icons.warning_amber_outlined,
      ),
      ShiftState.unknown => (
        'Loading shift',
        colors.onSurfaceVariant,
        Icons.hourglass_empty,
      ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Here is an overview of your current shift.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        );

        final status = Chip(
          avatar: Icon(statusIcon, size: 18, color: statusColor),
          label: Text(statusLabel),
          visualDensity: VisualDensity.compact,
          side: BorderSide.none,
          backgroundColor: statusColor.withValues(alpha: 0.10),
          labelStyle: theme.textTheme.labelMedium?.copyWith(color: statusColor),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 12), status],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 12),
            status,
          ],
        );
      },
    );
  }
}
