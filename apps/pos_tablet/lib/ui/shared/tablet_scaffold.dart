import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TabletScaffold extends StatelessWidget {
  const TabletScaffold({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _NavigationItem(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
    ),
    _NavigationItem(
      label: 'New Sale',
      icon: Icons.point_of_sale_outlined,
      route: '/sales',
    ),
    _NavigationItem(
      label: 'Stock Receiving',
      icon: Icons.inventory_2_outlined,
      route: '/stock-receiving',
    ),
    _NavigationItem(
      label: 'Sale History',
      icon: Icons.payments_outlined,
      route: '/sales-history',
    ),
    _NavigationItem(
      label: 'Shift',
      icon: Icons.schedule_outlined,
      route: '/shift',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 225,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
                    child: Row(
                      children: [
                        Icon(Icons.storefront_outlined, size: 30),
                        SizedBox(width: 12),
                        Text(
                          'POS Terminal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      children: _destinations.map((item) {
                        final selected = currentLocation == item.route;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            leading: Icon(item.icon),
                            title: Text(item.label),
                            selected: selected,
                            selectedTileColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onTap: () => context.go(item.route),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Exit demo'),
                    onTap: () => context.go('/login'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: SafeArea(child: child)),
        ],
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
