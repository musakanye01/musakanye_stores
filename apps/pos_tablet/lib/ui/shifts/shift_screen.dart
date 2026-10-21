import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/util/result.dart';

import '../shared/tablet_scaffold.dart'; // Adjust to your actual path.

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  bool _showClosingSummary = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Loads the open shift. The ViewModel should then load
      // the sales summary for that shift.
      context.read<ShiftViewModel>().loadOpenShift.execute();
    });
  }

  String _money(int cents) {
    final dollars = cents ~/ 100;
    final remainder = (cents % 100).abs().toString().padLeft(2, '0');
    return '\$$dollars.$remainder';
  }

  Future<Map<String, Object?>?> _askClosingDetails() async {
    final cashController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final details = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close shift?'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Count the physical cash in the till. '
                'Do not include EcoCash or bank transfers.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cashController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Physical cash counted (USD)',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');

                  if (amount == null ||
                      !amount.isFinite ||
                      amount < 0 ||
                      amount > 90000000000000 ||
                      (amount * 100 - (amount * 100).round()).abs() > 0.0001) {
                    return 'Enter a valid amount with up to 2 decimals.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Closing note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;

              final amount = double.parse(cashController.text.trim());

              Navigator.pop(dialogContext, {
                'countedCashCents': (amount * 100).round(),
                'closingNote': noteController.text.trim(),
              });
            },
            child: const Text('Confirm Close'),
          ),
        ],
      ),
    );

    // Allow the dialog route to finish its dismissal before disposing
    // the controllers used by its form fields.
    await WidgetsBinding.instance.endOfFrame;

    cashController.dispose();
    noteController.dispose();

    return details;
  }

  Future<void> _confirmCloseShift() async {
    final details = await _askClosingDetails();

    if (details == null || !mounted) return;

    final viewModel = context.read<ShiftViewModel>();

    final result = await viewModel.closeCurrentShift(
      countedCashCents: details['countedCashCents'] as int,
      closingNote: (details['closingNote'] as String).isEmpty
          ? null
          : details['closingNote'] as String,
    );

    if (!mounted) return;

    switch (result) {
      case Ok<void>():
        setState(() {
          _showClosingSummary = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shift closed successfully.')),
        );

      case Error<void>(error: final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not close shift: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ShiftViewModel>();
    final shift = viewModel.currentShift;
    final summary = viewModel.salesSummary;

    final isOpen = shift?.status == 'open';

    return TabletScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Shift',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Review your sales and manage your shift.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(isOpen: isOpen),
              ],
            ),
            const SizedBox(height: 24),

            if (viewModel.isLoadingSummary)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              ),

            if (viewModel.summaryError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline),
                      const SizedBox(width: 12),
                      Expanded(child: Text(viewModel.summaryError!)),
                      IconButton(
                        tooltip: 'Retry loading sales',
                        onPressed: () {
                          if (shift != null) {
                            viewModel.loadSalesSummary();
                          } else {
                            viewModel.loadOpenShift.execute();
                          }
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _summaryCard(
                  'Cash Sales',
                  _money(summary.cashSalesCents),
                  Icons.point_of_sale,
                ),
                _summaryCard(
                  'EcoCash Sales',
                  _money(summary.ecoCashSalesCents),
                  Icons.phone_android,
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (shift == null && !_showClosingSummary)
              _sectionCard(
                title: 'No Open Shift',
                child: const Text(
                  'There is no open shift for your account. '
                  'Open a shift before recording sales.',
                ),
              ),

            if (isOpen)
              _sectionCard(
                title: 'Close Shift',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Finish your sales and count the physical cash '
                      'in the till before closing.',
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: viewModel.isClosingShift
                            ? null
                            : _confirmCloseShift,
                        icon: viewModel.isClosingShift
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.lock_outline),
                        label: Text(
                          viewModel.isClosingShift
                              ? 'Closing...'
                              : 'Close Shift',
                        ),
                      ),
                    ),
                    if (viewModel.closeError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        viewModel.closeError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            if (_showClosingSummary)
              _sectionCard(
                title: 'Shift Closed',
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('This shift has been closed successfully.'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 9, color: color),
          const SizedBox(width: 8),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
