import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sales/viewmodel/sales_history_view_model.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:pos_tablet/ui/shared/sync_badge.dart';
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
    return TabletScaffold(
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: SalesHistoryBody(),
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
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    // The view model keeps the query across navigation, so the field must too.
    _search = TextEditingController(
      text: context.read<SalesHistoryViewModel>().searchQuery,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalesHistoryViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales History',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _search,
          onChanged: vm.setSearchQuery,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Search loaded sales',
            hintText: 'Receipt ID, payment method, status or cents',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildBody(context, vm)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, SalesHistoryViewModel vm) {
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
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: sales.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final sale = sales[index];

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                title: Text(
                  formatUsd(sale.totalCents),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SyncBadge(sale.syncStatus),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
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
            padding: const EdgeInsets.all(8),
            child: Text(
              vm.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (vm.hasMore || vm.isLoadingMore)
          Padding(
            padding: const EdgeInsets.all(8),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 40,
          ), // was cloud_off; this is a local read now
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
