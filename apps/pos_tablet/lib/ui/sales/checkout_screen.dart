import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sales/viewmodel/catalogue_view_model.dart';
import 'package:pos_tablet/ui/sales/viewmodel/checkout_view_model.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:provider/provider.dart';

import '../shared/tablet_scaffold.dart';

import 'cart_item.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.items = const []});

  final List<CartItem> items;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _amountReceivedController = TextEditingController();
  late final CheckoutViewModel _checkoutViewModel;

  String _method = 'cash'; // 'cash' | 'ecocash_usd'

  static const _methodLabels = {'cash': 'Cash', 'ecocash_usd': 'EcoCash (USD)'};

  @override
  void initState() {
    super.initState();
    _checkoutViewModel = context.read<CheckoutViewModel>();
    _checkoutViewModel.completeSale.addListener(_onSaleResult);
  }

  @override
  void dispose() {
    _checkoutViewModel.completeSale.removeListener(_onSaleResult);
    _amountReceivedController.dispose();
    super.dispose();
  }

  // Items from the route if present, otherwise the shared cart.
  List<CartItem> get _items => widget.items.isNotEmpty
      ? widget.items
      : context.read<CatalogueViewModel>().cart;

  bool get _isCash => _method == 'cash';

  // ---- Money (all in cents) ----
  int get _totalCents => _items.fold<int>(
    0,
    (sum, i) => sum + (i.unitPrice * 100).round() * i.quantity,
  );

  int? get _receivedCents {
    final amount = double.tryParse(_amountReceivedController.text.trim());
    if (amount == null || !amount.isFinite || amount < 0) return null;
    final cents = (amount * 100).round();
    if ((amount * 100 - cents).abs() > 0.000001) return null;
    return cents;
  }

  int get _changeCents {
    final received = _receivedCents ?? 0;
    return received > _totalCents ? received - _totalCents : 0;
  }

  bool get _canCompleteSale {
    if (_items.isEmpty) return false;
    if (!_isCash) return true;
    final received = _receivedCents;
    return received != null && received >= _totalCents;
  }

  String _usd(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  // ---- Actions ----
  void _completeSale() {
    if (!_canCompleteSale) {
      _showError(
        _isCash
            ? 'Enter an amount that covers the sale total.'
            : 'There are no items in this sale.',
      );
      return;
    }

    final shift = context.read<ShiftViewModel>().currentShift;
    if (shift == null) {
      _showError('No open shift. Start a shift before selling.');
      return;
    }

    _checkoutViewModel.completeSale.execute(
      CheckoutInput(
        shiftId: shift.id,
        items: _items,
        // method: _method,
        tenderedCents: _receivedCents!,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _onSaleResult() {
    final command = _checkoutViewModel.completeSale;

    if (command.error) {
      final message = command.result.toString().replaceAll('Exception: ', '');
      command.clearResult();
      if (!mounted) return;
      _showError(message);

      if (message.contains('stock') || message.contains('available')) {
        context.read<CatalogueViewModel>().loadCatalogue.execute();
      }
      return;
    }

    if (command.completed) {
      final sale = _checkoutViewModel.lastSale;
      command.clearResult();
      if (sale == null || !mounted) return;

      final items = List<CartItem>.of(_items);
      final tendered = _isCash
          ? (_receivedCents ?? sale.totalCents)
          : sale.totalCents;
      final change = _isCash ? tendered - sale.totalCents : 0;

      final catalogue = context.read<CatalogueViewModel>();
      catalogue.clearCart();
      catalogue.loadCatalogue.execute();

      context.goNamed(
        'receipt',
        extra: {
          'saleId': sale.saleId,
          'items': items,
          'paymentMethod': _methodLabels[_method],
          'total': sale.totalCents / 100,
          'amountReceived': tendered / 100,
          'change': change / 100,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = context
        .watch<CheckoutViewModel>()
        .completeSale
        .running;
    // Rebuild when the shared cart changes, in case we're using it.
    context.watch<CatalogueViewModel>();

    return TabletScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back to cart',
                  onPressed: isProcessing
                      ? null
                      : () => context.goNamed(
                          'cart',
                          extra: List<CartItem>.of(_items),
                        ),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Text(
                  'Checkout',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildSummary(context)),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: _buildPayment(context, isProcessing),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final items = _items;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sale Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No items in this sale.'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  Text(
                                    '${item.quantity} × '
                                    '\$${item.unitPrice.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${item.total.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  _usd(_totalCents),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayment(BuildContext context, bool isProcessing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Select one payment method'),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _method,
              onChanged: (value) {
                if (value == null || isProcessing) return;
                setState(() => _method = value);
              },
              child: Column(
                children: _methodLabels.entries
                    .map(
                      (e) => RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(e.value),
                        value: e.key,
                      ),
                    )
                    .toList(),
              ),
            ),
            if (_isCash) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _amountReceivedController,
                enabled: !isProcessing,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount received (USD)',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text('Change due')),
                  Text(
                    _usd(_changeCents),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'Confirm the customer\'s EcoCash payment of '
                '${_usd(_totalCents)} has been received before completing the sale.',
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_canCompleteSale && !isProcessing)
                    ? _completeSale
                    : null,
                icon: isProcessing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(isProcessing ? 'Processing...' : 'Complete Sale'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
