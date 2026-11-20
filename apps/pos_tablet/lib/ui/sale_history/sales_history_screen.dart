import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sale_history/viewmodel/sales_history_view_model.dart';
import 'package:pos_tablet/ui/sale_history/widget/sale_history_tile.dart';
import 'package:pos_tablet/ui/shared/tablet_scaffold.dart';
import 'package:provider/provider.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Sales rung up since this screen was last open appear on entry. If a load
    // is already running (e.g. the view model was just created), this is a no-op.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SalesHistoryViewModel>().loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const TabletScaffold(
      // Same outer structure as the sale screen: SafeArea + 20dp padding.
      child: SafeArea(
        child: Padding(padding: EdgeInsets.all(20), child: SalesHistoryBody()),
      ),
    );
  }
}

/// The screen's content, separate from the scaffold so it can be tested alone.
class SalesHistoryBody extends StatefulWidget {
  const SalesHistoryBody({super.key});

  @override
  State<SalesHistoryBody> createState() => _SalesHistoryBodyState();
}

class _SalesHistoryBodyState extends State<SalesHistoryBody> {
  late final SalesHistoryViewModel _viewModel;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SalesHistoryViewModel>();
    // The view model keeps the query across navigation, so the field must too.
    _search = TextEditingController(text: _viewModel.searchQuery);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // The title and search field don't depend on the list, so only
    // _SalesList (below) watches the view model.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sales History', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),

        // Same field styling as the catalogue search.
        TextField(
          controller: _search,
          onChanged: _viewModel.setSearchQuery,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search loaded sales by receipt ID, payment method, status or cents',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: colors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Expanded(child: _SalesList()),
      ],
    );
  }
}

class _SalesList extends StatelessWidget {
  const _SalesList();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalesHistoryViewModel>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Block the screen only on the very first load. Reloads keep the list visible.
    if (vm.isLoading && vm.sales.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.sales.isEmpty) {
      return _ErrorState(message: vm.errorMessage!, onRetry: vm.loadInitial);
    }

    final sales = vm.filteredSales;

    if (sales.isEmpty) {
      return Center(
        child: Text(
          vm.sales.isEmpty
              ? 'No sales in this shift yet.'
              : 'No sales match your search.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: sales.length,
            // Same 10dp rhythm as the cart lines.
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final sale = sales[index];

              return SaleHistoryTile(
                sale: sale,
                onTap: () => context.goNamed(
                  'receipt',
                  pathParameters: {'saleId': sale.id},
                ),
              );
            },
          ),
        ),
        if (vm.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              vm.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ),
        if (vm.hasMore || vm.isLoadingMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
              onPressed: vm.isLoadingMore ? null : vm.loadMore,
              child: vm.isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load more sales'),
            ),
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Was cloud_off; this is a local read now.
          Icon(Icons.error_outline, size: 40, color: colors.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
