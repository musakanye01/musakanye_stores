import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sales/viewmodel/catalogue_view_model.dart';
import 'package:provider/provider.dart';

import '../shared/tablet_scaffold.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogueViewModel>();
    final cart = vm.cart;

    return TabletScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  tooltip: 'Back to catalogue',
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Shopping Cart',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Text(
                  '${vm.cartItemCount} items',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cart contents
            Expanded(
              child: cart.isEmpty
                  ? _buildEmptyCart(context)
                  : ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = cart[index];

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 36,
                                ),
                                const SizedBox(width: 16),

                                // Product details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.unitPrice.toStringAsFixed(2)} each',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity controls
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Decrease quantity',
                                      onPressed: () =>
                                          vm.decreaseQuantity(item.productId),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 32,
                                      child: Text(
                                        '${item.quantity}',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Increase quantity',
                                      onPressed: () {
                                        final increased = vm.increaseQuantity(
                                          item.productId,
                                        );

                                        if (!increased && context.mounted) {
                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'No more stock available '
                                                  'for this item.',
                                                ),
                                              ),
                                            );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 20),

                                // Line total
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    '\$${item.total.toStringAsFixed(2)}',
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Remove item
                                IconButton(
                                  tooltip: 'Remove item',
                                  onPressed: () =>
                                      vm.removeFromCart(item.productId),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 32),

            // Cart summary and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subtotal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${vm.cartTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: cart.isEmpty ? null : () => vm.clearCart(),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear cart'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: cart.isEmpty
                      ? null
                      : () => context.goNamed('checkout'),
                  icon: const Icon(Icons.payment),
                  label: const Text('Proceed to Checkout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Return to the catalogue to add products.'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.goNamed("sales"),
            icon: const Icon(Icons.storefront),
            label: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }
}
