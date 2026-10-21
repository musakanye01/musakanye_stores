import 'package:flutter/material.dart';
import 'package:owner/ui/stock/widgets/inventory_colors.dart';

class InventoryEmptyState extends StatelessWidget {
  const InventoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: InventoryColors.muted,
          ),
          SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Try another search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: InventoryColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
