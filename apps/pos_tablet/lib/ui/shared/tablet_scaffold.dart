import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/shared/widget/app_nav_rail.dart';

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  // Starts collapsed on every application launch.
  bool _expanded = false;

  static const double _mobileBreakpoint = 600;
  static const double _wideBreakpoint = 1000;

  static const List<AppNavigationDestination> _destinations = [
    AppNavigationDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      route: '/dashboard',
    ),
    AppNavigationDestination(
      label: 'Sale',
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale_rounded,
      route: '/sales',
    ),
    AppNavigationDestination(
      label: 'Sale History',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      route: '/sales-history',
    ),
    AppNavigationDestination(
      label: 'Shift',
      icon: Icons.access_time_outlined,
      selectedIcon: Icons.access_time_filled_rounded,
      route: '/shift',
    ),
  ];

  int _selectedIndex(String location) {
    if (location.startsWith('/sales') ||
        location.startsWith('/checkout') ||
        location.startsWith('/cart') ||
        location.startsWith('/receipt')) {
      // Receipt routes belong to the sales workflow.
      return location.startsWith('/receipt') ? 2 : 1;
    }

    if (location.startsWith('/shift') ||
        location.startsWith('/start-shift') ||
        location.startsWith('/cash-movements')) {
      return 3;
    }

    return 0;
  }

  void _navigateTo(int index) {
    if (index < 0 || index >= _destinations.length) return;

    final route = _destinations[index].route;

    if (mounted) {
      context.go(route);
    }

    if (_expanded && MediaQuery.sizeOf(context).width < _wideBreakpoint) {
      setState(() => _expanded = false);
    }
  }

  Widget _buildNavigation({
    required int selectedIndex,
    required bool expanded,
    bool overlay = false,
  }) {
    return AppNavigationRail(
      expanded: expanded,
      selectedIndex: selectedIndex,
      destinations: _destinations,
      onToggle: () {
        setState(() => _expanded = !_expanded);
      },
      onDestinationSelected: _navigateTo,
      onExit: () {},
      overlay: overlay,
    );
  }

  Widget _buildMobileNavigation(int selectedIndex) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: _navigateTo,
      destinations: [
        for (final destination in _destinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: destination.label,
          ),
      ],
    );
  }

  Widget _buildWideLayout(int selectedIndex) {
    return Row(
      children: [
        _buildNavigation(selectedIndex: selectedIndex, expanded: _expanded),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildConstrainedLayout(int selectedIndex) {
    return Stack(
      children: [
        Row(
          children: [
            _buildNavigation(selectedIndex: selectedIndex, expanded: false),
            Expanded(child: widget.child),
          ],
        ),

        if (_expanded) ...[
          Positioned.fill(
            left: AppNavigationRail.collapsedWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _expanded = false),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.16)),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: _buildNavigation(
              selectedIndex: selectedIndex,
              expanded: true,
              overlay: true,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndex(location);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < _mobileBreakpoint) {
          return Scaffold(
            body: widget.child,
            bottomNavigationBar: _buildMobileNavigation(selectedIndex),
          );
        }

        return Scaffold(
          body: width < _wideBreakpoint
              ? _buildConstrainedLayout(selectedIndex)
              : _buildWideLayout(selectedIndex),
        );
      },
    );
  }
}
