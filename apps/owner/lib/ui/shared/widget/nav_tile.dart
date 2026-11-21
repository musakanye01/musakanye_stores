import 'package:flutter/material.dart';
import 'package:owner/ui/shared/nav_destination.dart';
import 'package:shared_core/theme/app_colors.dart';
import 'package:shared_core/theme/app_spacing.dart';

class OwnerNavigationTile extends StatelessWidget {
  const OwnerNavigationTile({
    super.key,
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final OwnerNavigationDestination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? AppColors.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    final icon = Icon(
      selected ? destination.selectedIcon : destination.icon,
      size: 24,
      color: foreground,
    );

    final label = Text(
      destination.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: foreground,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Tooltip(
        message: expanded ? '' : destination.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubicEmphasized,
              width: double.infinity,
              constraints: BoxConstraints(minHeight: expanded ? 56 : 72),
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? AppSpacing.md : AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: expanded
                  ? Row(
                      children: [
                        icon,
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: label),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        icon,
                        const SizedBox(height: AppSpacing.xxs),
                        label,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
