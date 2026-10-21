import 'package:flutter/material.dart';
import 'package:owner/ui/stock/inventory_view_model.dart';
import 'package:owner/ui/stock/widgets/inventory_colors.dart';
import 'package:owner/ui/stock/widgets/inventory_empty_state.dart';
import 'package:owner/ui/stock/widgets/inventory_search_field.dart';
import 'package:owner/ui/stock/widgets/inventory_summary_row.dart';
import 'package:owner/ui/stock/widgets/product_card.dart';
import 'package:owner/ui/stock/widgets/product_details_sheet.dart';
import 'package:owner/ui/stock/widgets/product_form_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

class OwnerInventoryScreen extends StatefulWidget {
  const OwnerInventoryScreen({super.key});

  @override
  State<OwnerInventoryScreen> createState() => _OwnerInventoryScreenState();
}

class _OwnerInventoryScreenState extends State<OwnerInventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = context.read<InventoryViewModel>();
      viewModel.loadInventory();
      viewModel.loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, viewModel, _) {
        final products = viewModel.filteredInventory;

        return Scaffold(
          backgroundColor: InventoryColors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: viewModel.isCreatingProduct
                ? null
                : () => _addProduct(viewModel),
            backgroundColor: InventoryColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add product'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: InventorySearchField(
                  controller: _searchController,
                  onChanged: viewModel.setSearchQuery,
                  onClear: () {
                    _searchController.clear();
                    viewModel.setSearchQuery('');
                  },
                ),
              ),
              Expanded(child: _buildProductList(viewModel, products)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList(
    InventoryViewModel viewModel,
    List<CatalogueItem> products,
  ) {
    if (viewModel.isLoading && viewModel.inventory.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null && viewModel.inventory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load products.'),
              const SizedBox(height: 12),
              Text(viewModel.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: viewModel.loadInventory,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        InventorySummaryRow(
          productCount: viewModel.productCount,
          totalUnits: viewModel.totalUnits,
          lowStockCount: viewModel.lowStockCount,
          lowStockFilterActive: viewModel.lowStockOnly,
          onToggleLowStock: viewModel.toggleLowStockFilter,
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Product list',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${products.length} items',
              style: const TextStyle(
                fontSize: 12,
                color: InventoryColors.muted,
              ),
            ),
          ],
        ),
        if (viewModel.lowStockOnly) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => viewModel.setLowStockFilter(false),
              icon: const Icon(Icons.filter_alt_off, size: 17),
              label: const Text('Clear low-stock filter'),
            ),
          ),
        ],
        const SizedBox(height: 10),
        if (products.isEmpty)
          const InventoryEmptyState()
        else
          for (final product in products)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(
                product: product,
                onTap: () => _showProductDetails(viewModel, product),
              ),
            ),
      ],
    );
  }

  void _showProductDetails(
    InventoryViewModel viewModel,
    CatalogueItem product,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsSheet(
        product: product,
        onEdit: () => _editProduct(viewModel, product),
      ),
    );
  }

  Future<void> _addProduct(InventoryViewModel viewModel) async {
    await viewModel.loadCategories();
    if (!mounted) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: ProductFormSheet(categories: viewModel.categories),
      ),
    );

    if (!mounted || saved != true) return;
    _showMessage('Product added.');
  }

  Future<void> _editProduct(
    InventoryViewModel viewModel,
    CatalogueItem product,
  ) async {
    await viewModel.loadCategories();
    if (!mounted) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: ProductFormSheet(
          product: product,
          categories: viewModel.categories,
        ),
      ),
    );

    if (!mounted || saved != true) return;
    _showMessage('Product updated.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
