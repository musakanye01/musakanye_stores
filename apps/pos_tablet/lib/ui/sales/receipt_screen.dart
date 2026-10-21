import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../shared/tablet_scaffold.dart';
import 'cart_item.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({
    super.key,
    required this.saleId,
    required this.items,
    required this.paymentMethod,
    required this.total,
    required this.amountReceived,
    required this.change,
  });

  final String saleId;
  final List<CartItem> items;
  final String paymentMethod;
  final double total;
  final double amountReceived;
  final double change;

  String get _receiptNumber => saleId;

  String _formatMoney(double amount) => '\$${amount.toStringAsFixed(2)}';

  String _formatDateTime(DateTime dateTime) {
    final date = dateTime.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');

    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  String _receiptText(DateTime dateTime) {
    final buffer = StringBuffer()
      ..writeln('SALE RECEIPT')
      ..writeln('Receipt: $_receiptNumber')
      ..writeln('Date: ${_formatDateTime(dateTime)}')
      ..writeln('--------------------------------');

    for (final item in items) {
      buffer
        ..writeln(item.name)
        ..writeln(
          '${item.quantity} x ${_formatMoney(item.unitPrice)}'
          ' = ${_formatMoney(item.total)}',
        );
    }

    buffer
      ..writeln('--------------------------------')
      ..writeln('Payment: $paymentMethod')
      ..writeln('TOTAL: ${_formatMoney(total)}');

    if (paymentMethod.toLowerCase() == 'cash') {
      buffer
        ..writeln('Received: ${_formatMoney(amountReceived)}')
        ..writeln('Change: ${_formatMoney(change)}');
    }

    buffer.writeln('\nThank you for shopping with us!');
    return buffer.toString();
  }

  Future<void> _shareReceipt(BuildContext context, DateTime dateTime) async {
    final text = _receiptText(dateTime);

    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Sale receipt $_receiptNumber'),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Temporary display time until we load the persisted sale timestamp.
    final displayedAt = DateTime.now();

    return TabletScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sale Receipt',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 56,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sale Complete',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text('Payment recorded'),
                          const SizedBox(height: 20),
                          const Divider(),
                          _ReceiptRow(
                            label: 'Receipt reference',
                            value: _receiptNumber,
                          ),
                          const SizedBox(height: 8),
                          _ReceiptRow(
                            label: 'Date and time',
                            value: _formatDateTime(displayedAt),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          Expanded(
                            child: ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 20),
                              itemBuilder: (context, index) {
                                final item = items[index];

                                return Row(
                                  children: [
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
                                          Text(
                                            '${item.quantity} × '
                                            '${_formatMoney(item.unitPrice)}',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(_formatMoney(item.total)),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Divider(),
                          _ReceiptRow(
                            label: 'Payment method',
                            value: paymentMethod,
                          ),
                          const SizedBox(height: 8),
                          _ReceiptRow(
                            label: 'Total',
                            value: _formatMoney(total),
                            bold: true,
                          ),
                          if (paymentMethod.toLowerCase() == 'cash') ...[
                            const SizedBox(height: 8),
                            _ReceiptRow(
                              label: 'Amount received',
                              value: _formatMoney(amountReceived),
                            ),
                            const SizedBox(height: 8),
                            _ReceiptRow(
                              label: 'Change',
                              value: _formatMoney(change),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Thank you for shopping with us!',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _shareReceipt(context, displayedAt),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share Receipt'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => context.goNamed('dashboard'),
                  icon: const Icon(Icons.dashboard_outlined),
                  label: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        const SizedBox(width: 16),
        Flexible(
          child: Text(value, textAlign: TextAlign.end, style: style),
        ),
      ],
    );
  }
}
