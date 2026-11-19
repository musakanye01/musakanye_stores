import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sales/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/sales/viewmodel/catalogue_view_model.dart';
import 'package:pos_tablet/ui/sales/widget/cart/cart_content.dart';
import 'package:pos_tablet/ui/sales/widget/product_card.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

import '../shared/tablet_scaffold.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  late final CatalogueViewModel _viewModel;
  late final TextEditingController _searchController;

  bool _cartPanelOpen = false;

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

  bool get _isLandscape =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  void _addToCart(CatalogueItem item) {
    final added = context.read<CartViewModel>().add(item);

    if (!added && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No more stock available for this item.'),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  void _openCart() {
    final cart = context.read<CartViewModel>();
    if (cart.isEmpty) return;

    if (_isLandscape) {
      setState(() => _cartPanelOpen = true);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) =>
          FractionallySizedBox(heightFactor: 0.9, child: const CartContent()),
    );
  }

  void _closeCartPanel() {
    setState(() => _cartPanelOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogueViewModel>();
    final cart = context.watch<CartViewModel>();
    final isLandscape = _isLandscape;

    return TabletScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Sale',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // Search remains above the entire catalogue area.
              TextField(
                controller: _searchController,
                onChanged: vm.setSearchQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products by name, SKU or category',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildBody(context, vm, cart)),

                    // Landscape cart panel overlays the catalogue.
                    if (isLandscape) ...[
                      if (_cartPanelOpen)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _closeCartPanel,
                            child: ColoredBox(
                              color: Colors.black.withValues(alpha: 0.24),
                            ),
                          ),
                        ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        top: 0,
                        bottom: 0,
                        left: _cartPanelOpen ? 0 : -420,
                        width: 400,
                        child: Material(
                          elevation: 12,
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CartContent(onClose: _closeCartPanel),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),
              _buildCartSummary(context, cart, isLandscape),
            ],
          ),
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
          textAlign: TextAlign.center,
        ),
      );
    }

    final items = vm.filteredItems;

    if (items.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 250,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final remaining = item.stockOnHand - cart.quantityOf(item.variantId);

        return ProductCard(
          item: item,
          remainingStock: remaining,
          onAdd: () => _addToCart(item),
        );
      },
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    CartViewModel cart,
    bool isLandscape,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: cart.isEmpty ? null : _openCart,
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
                      '${cart.itemCount} items in cart',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatUsd(cart.totalCents),
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (!cart.isEmpty)
                FilledButton.icon(
                  onPressed: _openCart,
                  icon: Icon(
                    isLandscape
                        ? Icons.shopping_cart_outlined
                        : Icons.keyboard_arrow_up,
                  ),
                  label: Text(isLandscape ? 'View Cart' : 'Review Cart'),
                )
              else
                Text(
                  'Add products to begin',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
