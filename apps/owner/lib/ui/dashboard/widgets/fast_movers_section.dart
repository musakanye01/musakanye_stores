import 'package:flutter/material.dart';
import 'package:shared_core/domain/model/dashboard_summary.dart';

class FastMoversSection extends StatelessWidget {
  const FastMoversSection({super.key, required this.products});

  final List<FastMovingProduct> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxUnits = products.fold<int>(
      0,
      (max, product) => product.unitsSold > max ? product.unitsSold : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fast-moving products',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Units sold in the last 7 days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            if (products.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No product sales yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              for (var i = 0; i < products.length; i++) ...[
                _ProductBar(product: products[i], maxUnits: maxUnits),
                if (i != products.length - 1) const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }
}

class _ProductBar extends StatelessWidget {
  const _ProductBar({required this.product, required this.maxUnits});

  final FastMovingProduct product;
  final int maxUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maxUnits == 0 ? 0.0 : product.unitsSold / maxUnits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${product.unitsSold} sold',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 7,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
