import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sales/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/sales/widget/cart/cart_line.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:provider/provider.dart';

/// Shared cart UI used by the standalone cart route, portrait bottom sheet,
/// and landscape sliding panel.
class CartContent extends StatelessWidget {
  const CartContent({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CartViewModel>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Your Cart', style: theme.textTheme.headlineSmall),
              ),
              Text('${vm.itemCount} items', style: theme.textTheme.titleSmall),
              const SizedBox(width: 8),
              IconButton(
                tooltip: onClose == null ? 'Back to sale' : 'Close cart',
                onPressed: onClose ?? () => context.goNamed('sales'),
                icon: Icon(onClose == null ? Icons.arrow_back : Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: vm.isEmpty
                ? _buildEmptyCart(context)
                : ListView.separated(
                    itemCount: vm.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = vm.items[index];

                      return CartLine(
                        item: item,
                        onDecrease: () => vm.decrease(item.variantId),
                        onIncrease: () {
                          final increased = vm.increase(item.variantId);

                          if (!increased && context.mounted) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No more stock available for this item.',
                                  ),
                                ),
                              );
                          }
                        },
                        onRemove: () => vm.remove(item.variantId),
                      );
                    },
                  ),
          ),

          const Divider(height: 28),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subtotal', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 3),
                    Text(
                      formatUsd(vm.totalCents),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!vm.isEmpty)
                OutlinedButton.icon(
                  onPressed: vm.clear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: vm.isEmpty ? null : () => context.goNamed('checkout'),
              icon: const Icon(Icons.payment),
              label: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: colors.outline),
          const SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Add products from the catalogue to start a sale.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
