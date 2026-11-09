import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:pos_tablet/ui/shifts/close_shift_dialog.dart';
import 'package:pos_tablet/ui/shifts/shift_summary_view_model.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/util/result.dart';

import '../shared/tablet_scaffold.dart';

class ShiftScreen extends StatelessWidget {
  const ShiftScreen({super.key});

  Future<void> _confirmCloseShift(BuildContext context) async {
    final details = await CloseShiftDialog.show(context);
    if (details == null || !context.mounted) return;

    // Taken before the await: a successful close flips the router, which can
    // unmount this screen before the call returns.
    final messenger = ScaffoldMessenger.of(context);

    final result = await context.read<ShiftViewModel>().closeCurrentShift(
      countedCashCents: details.countedCashCents,
      closingNote: details.note,
    );

    // On failure the view model's closeError is shown inline below.
    if (result is Ok<void>) {
      messenger.showSnackBar(const SnackBar(content: Text('Shift closed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftVm = context.watch<ShiftViewModel>();
    final summaryVm = context.watch<ShiftSummaryViewModel>(); // watch, not read
    final summary = summaryVm.summary;
    final isOpen = shiftVm.state == ShiftState.open;

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

            if (summaryVm.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Could not read sales totals from this device.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                  formatUsd(summary.cashSalesCents),
                  Icons.point_of_sale,
                ),
                _summaryCard(
                  'EcoCash Sales',
                  formatUsd(summary.ecoCashSalesCents),
                  Icons.phone_android,
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!isOpen)
              _sectionCard(
                title: 'No Open Shift',
                child: const Text(
                  'There is no open shift. Start a shift before recording sales.',
                ),
              ),

            if (isOpen)
              _sectionCard(
                title: 'Close Shift',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Finish your sales and count the physical cash in the till before closing.',
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: shiftVm.isClosingShift
                            ? null
                            : () => _confirmCloseShift(context),
                        icon: shiftVm.isClosingShift
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.lock_outline),
                        label: Text(
                          shiftVm.isClosingShift ? 'Closing...' : 'Close Shift',
                        ),
                      ),
                    ),
                    if (shiftVm.closeError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        shiftVm.closeError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
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

// _StatusBadge unchanged.

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
