import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sales/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/sales/viewmodel/catalogue_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

import '../shared/tablet_scaffold.dart';

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(CatalogueItem item) {
    context.read<CartViewModel>().add(item);
  }

  void _openCart() {
    if (context.read<CartViewModel>().isEmpty) return;
    context.goNamed('cart');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogueViewModel>();
    final cart = context.watch<CartViewModel>();

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
            Expanded(child: _buildBody(context, vm, cart)),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cart: ${cart.itemCount} items · '
                    '\$${(cart.totalCents / 100).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: cart.isEmpty ? null : _openCart,
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

  Widget _buildBody(
    BuildContext context,
    CatalogueViewModel vm,
    CartViewModel cart,
  ) {
    if (!vm.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.items.isEmpty) {
      return const Center(
        child: Text('Could not read the product list from this device.'),
      );
    }
    if (vm.isCatalogueEmpty) {
      return const Center(
        child: Text(
          'No products yet. Connect to the internet once to download the catalogue.',
        ),
      );
    }

    final items = vm.filteredItems;
    if (items.isEmpty) return const Center(child: Text('No products found.'));

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
        final remaining = item.stockOnHand - cart.quantityOf(item.variantId);
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
