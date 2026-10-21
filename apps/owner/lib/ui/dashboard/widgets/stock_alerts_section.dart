import 'package:flutter/material.dart';
import 'package:owner/ui/dashboard/widgets/dashboard_colors.dart';
import 'package:owner/ui/dashboard/widgets/status_chip.dart';

class LowStockItem {
  const LowStockItem({
    required this.name,
    required this.category,
    required this.stock,
  });

  final String name;
  final String category;
  final int stock;
}

class StockAlertsSection extends StatelessWidget {
  const StockAlertsSection({
    super.key,
    required this.items,
    required this.onViewInventory,
  });

  final List<LowStockItem> items;
  final VoidCallback onViewInventory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Stock alerts',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: onViewInventory,
              child: const Text('View stock'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [for (final item in items) _StockRow(item: item)],
            ),
          ),
        ),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.item});

  final LowStockItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: DashboardColors.surfaceTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: DashboardColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: const TextStyle(
                    color: DashboardColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          LowStockChip(quantity: item.stock),
        ],
      ),
    );
  }
}
