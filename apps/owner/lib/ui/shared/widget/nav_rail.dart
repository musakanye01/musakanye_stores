import 'package:flutter/material.dart';
import 'package:owner/ui/shared/nav_destination.dart';
import 'package:owner/ui/shared/widget/nav_tile.dart';
import 'package:shared_core/theme/app_colors.dart';
import 'package:shared_core/theme/app_spacing.dart';

class OwnerNavigationRail extends StatelessWidget {
  const OwnerNavigationRail({
    super.key,
    required this.expanded,
    required this.selectedIndex,
    required this.destinations,
    required this.onToggle,
    required this.onDestinationSelected,
    this.overlay = false,
  });

  final bool expanded;
  final int selectedIndex;
  final List<OwnerNavigationDestination> destinations;
  final VoidCallback onToggle;
  final ValueChanged<int> onDestinationSelected;
  final bool overlay;

  static const double collapsedWidth = 96;
  static const double expandedWidth = 280;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: overlay ? 4 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubicEmphasized,
        width: expanded ? expandedWidth : collapsedWidth,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: expanded ? AppSpacing.md : AppSpacing.xs,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: expanded
                          ? 'Collapse navigation'
                          : 'Expand navigation',
                      onPressed: onToggle,
                      icon: Icon(
                        expanded ? Icons.menu_open_rounded : Icons.menu_rounded,
                      ),
                    ),
                    if (expanded) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Owner',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < destinations.length; index++)
                        OwnerNavigationTile(
                          destination: destinations[index],
                          selected: selectedIndex == index,
                          expanded: expanded,
                          onTap: () => onDestinationSelected(index),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
