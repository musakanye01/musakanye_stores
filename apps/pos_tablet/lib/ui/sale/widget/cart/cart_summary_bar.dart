import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sale/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:provider/provider.dart';

/// Bottom summary bar. Selects only the three cart values it displays.
class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    super.key,
    required this.isLandscape,
    required this.panelOpen,
    required this.onPressed,
  });

  final bool isLandscape;
  final bool panelOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isEmpty = context.select((CartViewModel cart) => cart.isEmpty);
    final itemCount = context.select((CartViewModel cart) => cart.itemCount);
    final totalCents = context.select((CartViewModel cart) => cart.totalCents);

    final showClose = isLandscape && panelOpen;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isEmpty ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'} in cart',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatUsd(totalCents),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEmpty)
                FilledButton.icon(
                  onPressed: onPressed,
                  icon: Icon(
                    showClose ? Icons.close : Icons.shopping_cart_outlined,
                  ),
                  label: Text(showClose ? 'Close Cart' : 'View Cart'),
                )
              else
                Text('Add products to begin', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
