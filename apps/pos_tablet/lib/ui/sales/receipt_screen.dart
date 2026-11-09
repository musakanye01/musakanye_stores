import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/di/app_dependencies.dart';
import 'package:pos_tablet/ui/sales/receipt_text.dart';
import 'package:pos_tablet/ui/sales/viewmodel/receipt_view_model.dart';
import 'package:pos_tablet/ui/shared/format.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:pos_tablet/ui/shared/sync_badge.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/sale_receipt.dart';
import 'package:shared_core/domain/model/sync_status.dart';
import 'package:share_plus/share_plus.dart';

import '../shared/tablet_scaffold.dart';

// import AppDependencies from its file

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          ReceiptViewModel(ctx.read<AppDependencies>().saleRepository, saleId),
      child: TabletScaffold(
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
              const Expanded(child: ReceiptBody()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading, error and not-found states around the receipt itself.
class ReceiptBody extends StatelessWidget {
  const ReceiptBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReceiptViewModel>();

    if (vm.isLoading) return const Center(child: CircularProgressIndicator());

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: vm.retry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final receipt = vm.receipt;
    if (receipt == null) {
      return const Center(
        child: Text('This receipt was not found on this device.'),
      );
    }
    return ReceiptView(receipt: receipt);
  }
}

class ReceiptView extends StatelessWidget {
  const ReceiptView({super.key, required this.receipt});

  final SaleReceipt receipt;

  Future<void> _share() => SharePlus.instance.share(
    ShareParams(
      text: buildReceiptText(receipt),
      subject: 'Sale receipt ${receipt.saleId}',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final r = receipt;

    return Column(
      children: [
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
                      if (r.syncStatus != SyncStatus.synced) ...[
                        const SizedBox(height: 8),
                        SyncBadge(r.syncStatus),
                      ],
                      const SizedBox(height: 20),
                      const Divider(),
                      _ReceiptRow(label: 'Receipt reference', value: r.saleId),
                      const SizedBox(height: 8),
                      _ReceiptRow(
                        label: 'Date and time',
                        value: formatDateTime(r.createdAt),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: r.lines.length,
                          separatorBuilder: (_, _) => const Divider(height: 20),
                          itemBuilder: (context, index) {
                            final line = r.lines[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        line.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        '${line.quantity} × ${formatUsd(line.unitPriceCents)}',
                                      ),
                                    ],
                                  ),
                                ),
                                Text(formatUsd(line.totalCents)),
                              ],
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      _ReceiptRow(
                        label: 'Payment method',
                        value: paymentMethodLabel(r.paymentMethod),
                      ),
                      const SizedBox(height: 8),
                      _ReceiptRow(
                        label: 'Total',
                        value: formatUsd(r.totalCents),
                        bold: true,
                      ),
                      if (r.isCash) ...[
                        const SizedBox(height: 8),
                        _ReceiptRow(
                          label: 'Amount received',
                          value: formatUsd(r.tenderedCents),
                        ),
                        const SizedBox(height: 8),
                        _ReceiptRow(
                          label: 'Change',
                          value: formatUsd(r.changeCents),
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
              onPressed: _share,
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
