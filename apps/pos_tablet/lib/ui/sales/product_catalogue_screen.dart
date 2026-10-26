import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sales/viewmodel/catalogue_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

import '../shared/tablet_scaffold.dart';
import 'cart_item.dart';

class ProductCatalogueScreen extends StatefulWidget {
  const ProductCatalogueScreen({super.key});

  @override
  State<ProductCatalogueScreen> createState() => _ProductCatalogueScreenState();
}

class _ProductCatalogueScreenState extends State<ProductCatalogueScreen> {
  late final CatalogueViewModel _viewModel;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<CatalogueViewModel>();
    _searchController = TextEditingController(text: _viewModel.searchQuery);

    if (_viewModel.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _viewModel.loadCatalogue.execute();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(CatalogueItem item) {
    _viewModel.addToCart(item);
    // ScaffoldMessenger.of(context)
    //   ..hideCurrentSnackBar()
    //   ..showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         added
    //             ? '${item.displayName} added to cart'
    //             : 'Only ${item.stockOnHand} of ${item.displayName} in stock.',
    //       ),
    //     ),
    //   );
  }

  void _openCart() {
    if (_viewModel.cart.isEmpty) return;
    context.goNamed('cart', extra: List<CartItem>.of(_viewModel.cart));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogueViewModel>();

    return TabletScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Catalogue',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name, SKU or category...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: vm.setSearchQuery,
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildBody(context, vm)),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cart: ${vm.cartItemCount} items · '
                    '\$${vm.cartTotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: vm.cart.isEmpty ? null : _openCart,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('View Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CatalogueViewModel vm) {
    final command = vm.loadCatalogue;

    if (command.running && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (command.error && vm.items.isEmpty) {
      final message = command.result.toString().replaceAll('Exception: ', '');
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => command.execute(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final items = vm.filteredItems;
    if (items.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 230,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final remaining = item.stockOnHand - vm.quantityInCart(item.variantId);
        final canAdd = remaining > 0;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 32),
                const SizedBox(height: 10),
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (item.variantLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(item.variantLabel!),
                ],
                if (item.categoryName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.categoryName!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  item.inStock
                      ? '${item.stockOnHand} in stock'
                      : 'Out of stock',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: item.inStock
                        ? null
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton.filled(
                      tooltip: 'Add to cart',
                      onPressed: canAdd ? () => _addToCart(item) : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
