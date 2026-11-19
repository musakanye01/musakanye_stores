
import 'package:flutter/material.dart';

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    super.key,
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    this.isPrimary = false,
    this.trendIcon,
  });

  final double width;
  final String label;
  final String value;
  final IconData icon;
  final bool isPrimary;
  final IconData? trendIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        color: isPrimary ? colors.primaryContainer : colors.surface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isPrimary
                        ? colors.onPrimaryContainer
                        : colors.primary,
                  ),
                  if (trendIcon != null)
                    Icon(
                      trendIcon,
                      size: 26,
                      color: const Color(0xFF16834A),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isPrimary
                      ? colors.onPrimaryContainer.withValues(alpha: 0.8)
                      : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: (isPrimary
                          ? theme.textTheme.headlineMedium
                          : theme.textTheme.headlineSmall)
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isPrimary
                        ? colors.onPrimaryContainer
                        : colors.onSurface,
                  ),
                ),
              ),
              if (isPrimary) ...[
                const SizedBox(height: 4),
                Text(
                  'Current shift',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
