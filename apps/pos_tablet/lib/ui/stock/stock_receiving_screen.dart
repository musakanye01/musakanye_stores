import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/stock/stock_receiving_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/stock_receiving_item.dart';

import '../shared/tablet_scaffold.dart';

class StockReceivingScreen extends StatefulWidget {
  const StockReceivingScreen({super.key});

  @override
  State<StockReceivingScreen> createState() => _StockReceivingScreenState();
}

class _StockReceivingScreenState extends State<StockReceivingScreen> {
  late final StockReceivingViewModel _viewModel;
  late final TextEditingController _quantityController;
  late final TextEditingController _noteController;
  late final TextEditingController _referenceController;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read<StockReceivingViewModel>();
    _quantityController = TextEditingController();
    _noteController = TextEditingController();
    _referenceController = TextEditingController();

    _viewModel.addListener(_syncFormControllers);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_viewModel.products.isEmpty) {
        _viewModel.loadProducts.execute();
      }

      _viewModel.loadRecentItems.execute();
    });
  }

  void _syncFormControllers() {
    if (_quantityController.text != _viewModel.quantityText) {
      _quantityController.value = TextEditingValue(
        text: _viewModel.quantityText,
        selection: TextSelection.collapsed(
          offset: _viewModel.quantityText.length,
        ),
      );
    }

    if (_noteController.text != _viewModel.note) {
      _noteController.value = TextEditingValue(
        text: _viewModel.note,
        selection: TextSelection.collapsed(offset: _viewModel.note.length),
      );
    }

    if (_referenceController.text != _viewModel.reference) {
      _referenceController.value = TextEditingValue(
        text: _viewModel.reference,
        selection: TextSelection.collapsed(offset: _viewModel.reference.length),
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncFormControllers);
    _quantityController.dispose();
    _noteController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _recordStock() async {
    await _viewModel.submitReceipt.execute();

    if (!mounted) return;

    final command = _viewModel.submitReceipt;
    final message = command.error
        ? command.result.toString().replaceAll('Exception: ', '')
        : 'Stock receipt submitted successfully.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDateTime(DateTime dateTime) {
    final date = dateTime.toLocal();

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${date.year}-${twoDigits(date.month)}-'
        '${twoDigits(date.day)} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockReceivingViewModel>();

    return TabletScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Receiving',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Record stock received from a supplier.'),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: vm.selectedVariantId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Product variant',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select product'),
                      items: vm.products.map((product) {
                        final variant = product.variantLabel;
                        final sku = product.sku;

                        final details = [
                          ?variant,
                          if (sku != null && sku.isNotEmpty) sku,
                        ].join(' · ');

                        return DropdownMenuItem<String>(
                          value: product.variantId,
                          child: Text(
                            details.isEmpty
                                ? product.productName
                                : '${product.productName} ($details)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: vm.submitting ? null : vm.selectVariant,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      enabled: !vm.submitting,
                      decoration: const InputDecoration(
                        labelText: 'Quantity received',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: vm.setQuantity,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _referenceController,
                      enabled: !vm.submitting,
                      decoration: const InputDecoration(
                        labelText: 'Reference (optional)',
                        hintText: 'Supplier invoice / delivery note',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: vm.setReference,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _noteController,
                      enabled: !vm.submitting,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        hintText: 'e.g. Supplier delivery',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      onChanged: vm.setNote,
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: vm.submitting || vm.products.isEmpty
                            ? null
                            : _recordStock,
                        icon: vm.submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(
                          vm.submitting ? 'Saving...' : 'Record Stock',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Recent Receipts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text('${vm.recentItems.length} entries'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildRecentItems(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItems(BuildContext context, StockReceivingViewModel vm) {
    if (vm.loadRecentItems.running && vm.recentItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.loadRecentItems.error && vm.recentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load recent receipts.'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => vm.loadRecentItems.execute(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.recentItems.isEmpty) {
      return const Center(child: Text('No stock receipts recorded yet.'));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        itemCount: vm.recentItems.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = vm.recentItems[index];
          return _buildReceiptTile(context, entry);
        },
      ),
    );
  }

  Widget _buildReceiptTile(BuildContext context, StockReceiptItem entry) {
    final details = [
      _formatDateTime(entry.receivedAt),
      if (entry.reference?.isNotEmpty == true) entry.reference!,
      if (entry.sku?.isNotEmpty == true) 'SKU: ${entry.sku}',
      if (entry.note.isNotEmpty) entry.note,
    ].join(' · ');

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
      title: Text(
        entry.variantLabel == null
            ? entry.productName
            : '${entry.productName} (${entry.variantLabel})',
      ),
      subtitle: Text(
        '$details\nStatus: ${entry.status}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      trailing: Text(
        '+${entry.quantity}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
