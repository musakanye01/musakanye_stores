import 'package:flutter/material.dart';
import 'package:owner/ui/dashboard/widgets/dashboard_colors.dart';
import 'package:owner/ui/dashboard/widgets/status_chip.dart';

class LowStockItem {
  const LowStockItem({required this.name, required this.stock});

  final String name;
  final int stock;
}

class StockAlertsSection extends StatelessWidget {
  const StockAlertsSection({
    super.key,
    required this.items,
    required this.totalCount,
    required this.onViewInventory,
  });

  final List<LowStockItem> items;
  final int totalCount;
  final VoidCallback onViewInventory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgentItems = [...items]..sort((a, b) => a.stock.compareTo(b.stock));
    final visibleItems = urgentItems.take(3).toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewInventory,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Stock alerts',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _AlertCount(count: totalCount),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Needs attention',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              if (visibleItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 17,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'No products running low.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (var i = 0; i < visibleItems.length; i++) ...[
                  _StockRow(item: visibleItems[i]),
                  if (i != visibleItems.length - 1) const SizedBox(height: 13),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertCount extends StatelessWidget {
  const _AlertCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = count > 0
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.item});

  final LowStockItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = item.stock <= 0;
    final alertColor = isOutOfStock
        ? theme.colorScheme.error
        : DashboardColors.warning;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: alertColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              LowStockChip(quantity: item.stock),
            ],
          ),
        ),
      ],
    );
  }
}
