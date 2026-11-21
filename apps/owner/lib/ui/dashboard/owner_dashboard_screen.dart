import 'package:flutter/material.dart';
import 'package:owner/ui/dashboard/dashboard_home.dart';
import 'package:owner/ui/dashboard/dashboard_view_model.dart';
import 'package:owner/ui/operations/owner_operations_screen.dart';
import 'package:owner/ui/shared/nav_destination.dart';
import 'package:owner/ui/shared/widget/nav_rail.dart';
import 'package:owner/ui/stock/owner_inventory_screen.dart';
import 'package:provider/provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  static const int _homeTab = 0;
  static const int _stockTab = 1;
  static const int _salesTab = 2;

  static const double _mobileBreakpoint = 600;
  static const double _wideBreakpoint = 1000;

  static const List<OwnerNavigationDestination> _destinations = [
    OwnerNavigationDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    OwnerNavigationDestination(
      label: 'Stock',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    OwnerNavigationDestination(
      label: 'Sales',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
  ];

  static const List<String> _titles = ['Dashboard', 'Stock', 'Sales'];

  int _selectedIndex = _homeTab;
  bool _expanded = false;

  void _select(int index) {
    if (index < 0 || index >= _destinations.length) return;

    setState(() {
      _selectedIndex = index;

      if (MediaQuery.sizeOf(context).width < _wideBreakpoint) {
        _expanded = false;
      }
    });
  }

  void _toggleRail() {
    setState(() => _expanded = !_expanded);
  }

  Widget _buildNavigation({required bool expanded, bool overlay = false}) {
    return OwnerNavigationRail(
      expanded: expanded,
      selectedIndex: _selectedIndex,
      destinations: _destinations,
      onToggle: _toggleRail,
      onDestinationSelected: _select,
      overlay: overlay,
    );
  }

  Widget _buildMobileNavigation() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _select,
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

  Widget _buildContent() {
    final dashboardViewModel = context.read<DashboardViewModel>();

    return IndexedStack(
      index: _selectedIndex,
      children: [
        DashboardHome(
          viewModel: dashboardViewModel,
          onOpenSales: () => _select(_salesTab),
          onOpenStock: () => _select(_stockTab),
        ),
        const OwnerInventoryScreen(),
        const OwnerOperationsScreen(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        _buildNavigation(expanded: _expanded),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildConstrainedLayout() {
    return Stack(
      children: [
        Row(
          children: [
            _buildNavigation(expanded: false),
            Expanded(child: _buildContent()),
          ],
        ),
        if (_expanded) ...[
          Positioned.fill(
            left: OwnerNavigationRail.collapsedWidth,
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
            child: _buildNavigation(expanded: true, overlay: true),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Scaffold(
          appBar: AppBar(title: Text(_titles[_selectedIndex])),
          body: SafeArea(
            top: false,
            child: width < _mobileBreakpoint
                ? _buildContent()
                : width < _wideBreakpoint
                ? _buildConstrainedLayout()
                : _buildWideLayout(),
          ),
          bottomNavigationBar: width < _mobileBreakpoint
              ? _buildMobileNavigation()
              : null,
        );
      },
    );
  }
}
