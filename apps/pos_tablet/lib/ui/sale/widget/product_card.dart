import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sale/widget/stock_chip.dart';
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

  /// Stock left after what is already in the cart.
  final int remainingStock;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isOutOfStock = remainingStock <= 0;

    // Dim the whole card when nothing is left to add.
    return Opacity(
      opacity: isOutOfStock ? 0.5 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: InkWell(
          // Always tappable: when out of stock the screen shows a
          // "no more stock" snackbar instead of silently ignoring the tap.
          onTap: onAdd,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name (leading) and static icon (trailing), top-aligned.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.child_care_rounded,
                        color: colors.onSecondaryContainer,
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
                ],

                // FIX: the chip now shows remaining stock (stock minus cart),
                // matching the tap/dim logic, and no longer depends on the
                // description being present.
                const SizedBox(height: 8),
                StockChip(stockOnHand: remainingStock),

                // Pushes the price to the bottom of the card.
                const Spacer(),
                const SizedBox(height: 8),

                // Price, leading-aligned at the bottom.
                Text(
                  formatUsd(item.priceCents),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
