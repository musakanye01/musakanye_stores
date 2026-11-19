import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sales/widget/stock_chip.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.item,
    required this.remainingStock,
    required this.onAdd,
  });

  final CatalogueItem item;
  final int remainingStock;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isOutOfStock = remainingStock <= 0;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: isOutOfStock ? null : onAdd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact image area: approximately 30% of card height.
            Expanded(
              flex: 2,
              child: SizedBox(
                width: double.infinity,
                child: ColoredBox(color: colors.surfaceContainerHigh),
              ),
            ),

            // Product information and actions.
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and price.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatUsd(item.priceCents),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),

                    // Variant / caption.
                    if (item.variantLabel != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.variantLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],

                    // Product description.
                    if (item.description?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.description!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 8),
                      StockChip(stockOnHand: item.stockOnHand),
                    ],

                    const SizedBox(height: 16),

                    // Stock chip and add action.
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: item.stockOnHand > 0
                                ? () => onAdd()
                                : null,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
