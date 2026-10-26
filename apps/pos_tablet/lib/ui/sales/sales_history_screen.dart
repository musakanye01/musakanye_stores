import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sales/cart_item.dart';
import 'package:pos_tablet/ui/sales/viewmodel/sales_history_view_model.dart';
import 'package:provider/provider.dart';

import 'package:pos_tablet/ui/shared/tablet_scaffold.dart';
import 'package:shared_core/domain/model/sale_history.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SalesHistoryView();
  }
}

class _SalesHistoryView extends StatelessWidget {
  const _SalesHistoryView();

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  String _date(DateTime value) {
    final d = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');

    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}';
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'ecocash_usd':
        return 'EcoCash (USD)';
      case 'bank_transfer_usd':
        return 'Bank transfer (USD)';
      default:
        return method;
    }
  }

  Future<void> _openReceipt(
    BuildContext context,
    SalesHistoryViewModel vm,
    SaleHistory sale,
  ) async {
    try {
      final data = await vm.loadReceipt(sale.id);
      if (!context.mounted) return;

      final saleData = data['sale'] as Map<String, dynamic>;
      final payment = data['payment'] as Map<String, dynamic>;
      final rawItems = data['items'] as List<Map<String, dynamic>>;

      final items = rawItems.map((row) {
        final description = row['variant_description'] as String?;
        final productName = row['product_name'] as String;
        final name = description == null || description.trim().isEmpty
            ? productName
            : '$productName — $description';

        return CartItem(
          productId: row['variant_id'] as String,
          name: name,
          quantity: (row['quantity'] as num).toInt(),
          unitPrice: (row['unit_price_cents'] as num).toInt() / 100,
        );
      }).toList();

      final method = payment['method'] as String;
      final amountCents = (payment['amount_cents'] as num).toInt();
      final tenderedCents =
          (payment['tendered_cents'] as num?)?.toInt() ?? amountCents;
      final changeCents = (payment['change_cents'] as num).toInt();

      final labels = {
        'cash': 'Cash',
        'ecocash_usd': 'EcoCash (USD)',
        'bank_transfer_usd': 'Bank transfer (USD)',
      };

      context.goNamed(
        'receipt',
        extra: {
          'saleId': sale.id,
          'items': items,
          'paymentMethod': labels[method] ?? method,
          'total': (saleData['total_cents'] as num).toInt() / 100,
          'amountReceived': tenderedCents / 100,
          'change': changeCents / 100,
          'createdAt': DateTime.parse(saleData['created_at'] as String),
        },
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open this receipt. Check your connection and retry.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalesHistoryViewModel>();

    return TabletScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales History',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
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
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SalesHistoryViewModel vm) {
    if (vm.isLoading) {
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
              ? 'No sales recorded yet.'
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
                  _money(sale.totalCents),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Receipt: ${sale.id}'),
                    Text(_date(sale.createdAt)),
                    Text(
                      '${_paymentLabel(sale.paymentMethod)} • ${sale.status}',
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openReceipt(context, vm, sale),
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
          const Icon(Icons.cloud_off, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
