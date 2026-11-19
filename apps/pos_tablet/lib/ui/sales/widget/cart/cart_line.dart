import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sales/cart_item.dart';
import 'package:pos_tablet/ui/shared/money.dart';

class CartLine extends StatelessWidget {
  const CartLine({
    super.key,
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;

            final details = Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${formatUsd(item.unitPriceCents)} each',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );

            final quantityControls = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Decrease quantity',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Increase quantity',
                  visualDensity: VisualDensity.compact,
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            );

            final lineTotal = Text(
              formatUsd(item.totalCents),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            );

            final removeButton = IconButton(
              tooltip: 'Remove item',
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: Icon(Icons.delete_outline, color: colors.error),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [details, const SizedBox(width: 8), lineTotal]),
                  const SizedBox(height: 6),
                  Row(
                    children: [quantityControls, const Spacer(), removeButton],
                  ),
                ],
              );
            }

            return Row(
              children: [
                details,
                const SizedBox(width: 12),
                quantityControls,
                const SizedBox(width: 12),
                lineTotal,
                const SizedBox(width: 4),
                removeButton,
              ],
            );
          },
        ),
      ),
    );
  }
}
