import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/checkout/widget/checkout_card.dart';
import 'package:pos_tablet/ui/sale/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:provider/provider.dart';

/// Line items and total for the sale being checked out.
/// Rebuilds only when the cart changes.
class SaleSummaryCard extends StatelessWidget {
  const SaleSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Consumer<CartViewModel>(
      builder: (context, cart, _) {
        final items = cart.items;

        return CheckoutCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sale Summary',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No items in this sale.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.quantity} × ${formatUsd(item.unitPriceCents)}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formatUsd(item.totalCents),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              // Same divider + total styling as the cart footer.
              const Divider(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text('Total', style: theme.textTheme.bodyMedium),
                  ),
                  Text(
                    formatUsd(cart.totalCents),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
