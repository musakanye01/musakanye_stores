import 'package:flutter/widgets.dart';

class OwnerNavigationDestination {
  const OwnerNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
