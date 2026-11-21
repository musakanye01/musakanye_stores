import 'package:flutter/material.dart';
import 'package:shared_core/domain/model/dashboard_summary.dart';

class FastMoversSection extends StatelessWidget {
  const FastMoversSection({
    super.key,
    required this.products,
    required this.onTap,
  });

  final List<FastMovingProduct> products;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topProducts = products.take(3).toList();
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Best sellers',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 15,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Last 7 days',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              if (topProducts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No product sales yet',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (var i = 0; i < topProducts.length; i++) ...[
                  _RankedProduct(product: topProducts[i], rank: i + 1),
                  if (i != topProducts.length - 1) const SizedBox(height: 13),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RankedProduct extends StatelessWidget {
  const _RankedProduct({required this.product, required this.rank});

  final FastMovingProduct product;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rank.toString().padLeft(2, '0'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${product.unitsSold} sold',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
