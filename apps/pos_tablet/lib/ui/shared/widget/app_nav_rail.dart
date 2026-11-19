import 'package:flutter/material.dart';
import 'package:shared_core/theme/app_colors.dart';
import 'package:shared_core/theme/app_spacing.dart';

class AppNavigationDestination {
  const AppNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.expanded,
    required this.selectedIndex,
    required this.destinations,
    required this.onToggle,
    required this.onDestinationSelected,
    required this.onExit,
    this.overlay = false,
  });

  final bool expanded;
  final int selectedIndex;
  final List<AppNavigationDestination> destinations;
  final VoidCallback onToggle;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onExit;
  final bool overlay;

  static const double collapsedWidth = 96;
  static const double expandedWidth = 280;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = expanded ? expandedWidth : collapsedWidth;

    return Material(
      color: theme.colorScheme.surface,
      elevation: overlay ? 4 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubicEmphasized,
        width: width,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < destinations.length; index++)
                        _NavigationDestinationTile(
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
              // _buildExitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? AppSpacing.md : AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: expanded ? 'Collapse navigation' : 'Expand navigation',
            onPressed: onToggle,
            icon: Icon(expanded ? Icons.menu_open_rounded : Icons.menu_rounded),
          ),
          if (expanded) ...[
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 180),
                child: Text(
                  'POS Terminal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavigationDestinationTile extends StatelessWidget {
  const _NavigationDestinationTile({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final AppNavigationDestination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final icon = Icon(
      selected ? destination.selectedIcon : destination.icon,
      size: 24,
      color: selected
          ? AppColors.onPrimaryContainer
          : colorScheme.onSurfaceVariant,
    );

    final label = Text(
      destination.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: selected
            ? AppColors.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
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
