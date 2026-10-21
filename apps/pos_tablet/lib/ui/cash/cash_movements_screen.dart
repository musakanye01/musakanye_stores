import 'package:flutter/material.dart';

import '../shared/tablet_scaffold.dart';

class CashMovementsScreen extends StatefulWidget {
  const CashMovementsScreen({super.key});

  @override
  State<CashMovementsScreen> createState() => _CashMovementsScreenState();
}

class _CashMovementsScreenState extends State<CashMovementsScreen> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  String _movementType = 'Cash Out';

  final List<_CashMovement> _movements = [];

  double get _totalCashIn {
    return _movements
        .where((movement) => movement.type == 'Cash In')
        .fold<double>(0, (sum, movement) => sum + movement.amount);
  }

  double get _totalCashOut {
    return _movements
        .where((movement) => movement.type == 'Cash Out')
        .fold<double>(0, (sum, movement) => sum + movement.amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _recordMovement() {
    final amount = double.tryParse(_amountController.text.trim());
    final reason = _reasonController.text.trim();

    if (amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        (amount * 100).roundToDouble() != amount * 100) {
      _showMessage('Enter a valid amount with up to two decimal places.');
      return;
    }

    if (reason.isEmpty) {
      _showMessage('Please enter a reason for this movement.');
      return;
    }

    setState(() {
      _movements.insert(
        0,
        _CashMovement(
          type: _movementType,
          amount: amount,
          reason: reason,
          recordedAt: DateTime.now(),
        ),
      );

      _amountController.clear();
      _reasonController.clear();
    });

    _showMessage('Cash movement recorded for this demo.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return TabletScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Movements',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Record cash added to or removed from the till. '
              'Every entry requires a reason.',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Cash In',
                    amount: _totalCashIn,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: 'Cash Out',
                    amount: _totalCashOut,
                    icon: Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: 'Net Movement',
                    amount: _totalCashIn - _totalCashOut,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _movementType,
                        decoration: const InputDecoration(
                          labelText: 'Movement type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Cash In',
                            child: Text('Cash In'),
                          ),
                          DropdownMenuItem(
                            value: 'Cash Out',
                            child: Text('Cash Out'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _movementType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount (USD)',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          hintText: 'e.g. Petty cash purchase',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: FilledButton.icon(
                        onPressed: _recordMovement,
                        icon: const Icon(Icons.add),
                        label: const Text('Record'),
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
                  'Movement History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text('${_movements.length} entries'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _movements.isEmpty
                  ? const Center(child: Text('No cash movements recorded yet.'))
                  : Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        itemCount: _movements.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final movement = _movements[index];
                          final isCashIn = movement.type == 'Cash In';

                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                isCashIn
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                              ),
                            ),
                            title: Text(movement.reason),
                            subtitle: Text(
                              '${movement.type} · '
                              '${_formatDateTime(movement.recordedAt)}',
                            ),
                            trailing: Text(
                              '${isCashIn ? '+' : '-'}'
                              '\$${movement.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date = dateTime.toLocal();

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}

class _CashMovement {
  const _CashMovement({
    required this.type,
    required this.amount,
    required this.reason,
    required this.recordedAt,
  });

  final String type;
  final double amount;
  final String reason;
  final DateTime recordedAt;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
  });

  final String title;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 6),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
