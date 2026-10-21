import 'package:flutter/material.dart';
import 'package:owner/ui/stock/widgets/inventory_colors.dart';

/// "Products" card (with total units on the trailing side) and a tappable
/// "Low stock" card that toggles the low-stock filter.
class InventorySummaryRow extends StatelessWidget {
  const InventorySummaryRow({
    super.key,
    required this.productCount,
    required this.totalUnits,
    required this.lowStockCount,
    required this.lowStockFilterActive,
    required this.onToggleLowStock,
  });

  final int productCount;
  final int totalUnits;
  final int lowStockCount;
  final bool lowStockFilterActive;
  final VoidCallback onToggleLowStock;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Products',
            value: '$productCount',
            icon: Icons.inventory_2_outlined,
            iconColor: InventoryColors.primary,
            backgroundColor: InventoryColors.primaryTint,
            trailingValue: '$totalUnits',
            trailingLabel: 'Units',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Low stock',
            value: '$lowStockCount',
            icon: Icons.warning_amber_rounded,
            iconColor: InventoryColors.lowStock,
            backgroundColor: InventoryColors.lowStockTint,
            onTap: onToggleLowStock,
            active: lowStockFilterActive,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
    this.active = false,
    this.trailingValue,
    this.trailingLabel,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool active;
  final String? trailingValue;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: active ? Border.all(color: iconColor, width: 1.5) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: iconColor, size: 21),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: InventoryColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (trailingValue != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          trailingValue!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trailingLabel ?? '',
                        style: const TextStyle(
                          color: InventoryColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
