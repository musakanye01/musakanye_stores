import 'package:flutter/material.dart';
import 'package:owner/ui/dashboard/dashboard_home.dart';
import 'package:owner/ui/dashboard/dashboard_view_model.dart';
import 'package:owner/ui/stock/owner_inventory_screen.dart';
import 'package:owner/ui/operations/owner_operations_screen.dart';
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

  int _selectedIndex = _homeTab;

  static const _titles = ['Dashboard', 'Stock', 'Sales'];

  void _select(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.read<DashboardViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
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
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Sales',
          ),
        ],
      ),
    );
  }
}
