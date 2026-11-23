import 'package:flutter/material.dart';
import 'package:owner/ui/stock/inventory_view_model.dart';
import 'package:owner/ui/stock/model/inventory_stock_filter.dart';
import 'package:owner/ui/stock/widgets/inventory_empty_state.dart';
import 'package:owner/ui/stock/widgets/inventory_search_field.dart';
import 'package:owner/ui/stock/widgets/inventory_summary_row.dart';
import 'package:owner/ui/stock/widgets/product_card.dart';
import 'package:owner/ui/stock/widgets/product_details_sheet.dart';
import 'package:owner/ui/stock/widgets/product_form_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/theme/app_colors.dart';

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
      final vm = context.read<InventoryViewModel>();
      vm.loadInventory();
      vm.loadCategories();
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
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: vm.isCreatingProduct ? null : () => _addProduct(vm),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add product'),
          ),
          body: SafeArea(child: _buildBody(vm)),
        );
      },
    );
  }

  Widget _buildBody(InventoryViewModel vm) {
    if (vm.isLoading && vm.inventory.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.inventory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load products.'),
              const SizedBox(height: 12),
              Text(vm.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: vm.loadInventory,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final products = vm.filteredInventory;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final horizontalPadding = wide ? 28.0 : 20.0;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: InventorySummaryRow(
                  productCount: vm.productCount,
                  totalUnits: vm.totalUnits,
                  lowStockCount: vm.lowStockCount,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Manage your products and inventory.',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: InventorySearchField(
                            controller: _searchController,
                            onChanged: vm.setSearchQuery,
                            onClear: () {
                              _searchController.clear();
                              vm.setSearchQuery('');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          tooltip: 'Filter products',
                          onPressed: () => _showFilters(vm),
                          icon: const Icon(Icons.tune_rounded),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(52, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildStatusChips(vm),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Products',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          '${products.length} items',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            if (products.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: InventoryEmptyState()),
              )
            else if (wide)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  100,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      product: products[index],
                      onTap: () => _showProductDetails(vm, products[index]),
                    ),
                    childCount: products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 440,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 116,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  100,
                ),
                sliver: SliverList.separated(
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    onTap: () => _showProductDetails(vm, products[index]),
                  ),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChips(InventoryViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statusChip(
            label: 'All products',
            count: vm.productCount,
            selected: vm.stockFilter == InventoryStockFilter.all,
            onTap: () => vm.setStockFilter(InventoryStockFilter.all),
          ),
          const SizedBox(width: 8),
          _statusChip(
            label: 'Low stock',
            count: vm.lowStockCount,
            selected: vm.stockFilter == InventoryStockFilter.lowStock,
            onTap: () => vm.setStockFilter(InventoryStockFilter.lowStock),
          ),
          const SizedBox(width: 8),
          _statusChip(
            label: 'Out of stock',
            count: vm.outOfStockCount,
            selected: vm.stockFilter == InventoryStockFilter.outOfStock,
            onTap: () => vm.setStockFilter(InventoryStockFilter.outOfStock),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text('$label  $count'),
      showCheckmark: false,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: selected ? AppColors.onPrimaryContainer : AppColors.muted,
      ),
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.outline,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _showFilters(InventoryViewModel vm) {
    // The composable filter sheet is the next implementation step.
    // Keep the control functional while that sheet is being introduced.
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text('More filter options will be added here.'),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(InventoryViewModel vm, CatalogueItem product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsSheet(
        product: product,
        onEdit: () => _editProduct(vm, product),
      ),
    );
  }

  Future<void> _addProduct(InventoryViewModel vm) async {
    await vm.loadCategories();
    if (!mounted) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: ProductFormSheet(categories: vm.categories),
      ),
    );

    if (!mounted || saved != true) return;
    _showMessage('Product added.');
  }

  Future<void> _editProduct(
    InventoryViewModel vm,
    CatalogueItem product,
  ) async {
    await vm.loadCategories();
    if (!mounted) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: ProductFormSheet(product: product, categories: vm.categories),
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
