import 'package:flutter/material.dart';

const _operationsBlue = Color(0xFF2457C5);
const _operationsMuted = Color(0xFF737B8C);
const _operationsBackground = Color(0xFFF7F8FC);

enum _ActivityType { shift, cash, stock, sale }

class _OperationRecord {
  const _OperationRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.icon,
    this.amount,
    this.details = '',
  });

  final String id;
  final _ActivityType type;
  final String title;
  final String subtitle;
  final String date;
  final String status;
  final IconData icon;
  final double? amount;
  final String details;
}

class OwnerOperationsScreen extends StatefulWidget {
  const OwnerOperationsScreen({super.key});

  @override
  State<OwnerOperationsScreen> createState() => _OwnerOperationsScreenState();
}

class _OwnerOperationsScreenState extends State<OwnerOperationsScreen> {
  String _selectedFilter = 'All';

  final List<_OperationRecord> _records = [
    const _OperationRecord(
      id: 'TXN-1048',
      type: _ActivityType.sale,
      title: 'Sale #1048',
      subtitle: 'Cash · 3 items',
      date: 'Today, 10:42 AM',
      status: 'Completed',
      icon: Icons.receipt_long_outlined,
      amount: 28.50,
      details: 'Sample sale with three items.',
    ),
    const _OperationRecord(
      id: 'SHIFT-006',
      type: _ActivityType.shift,
      title: 'Cashier shift',
      subtitle: 'Opening float: \$50.00',
      date: 'Today, 8:30 AM',
      status: 'Open',
      icon: Icons.point_of_sale_outlined,
      amount: 50.00,
      details: 'Demo shift. Closing reconciliation has not been recorded.',
    ),
    const _OperationRecord(
      id: 'CASH-023',
      type: _ActivityType.cash,
      title: 'Cash out',
      subtitle: 'Petty cash',
      date: 'Today, 9:15 AM',
      status: 'Recorded',
      icon: Icons.arrow_upward_rounded,
      amount: -8.00,
      details: 'Sample cash-out entry for petty cash.',
    ),
    const _OperationRecord(
      id: 'STOCK-012',
      type: _ActivityType.stock,
      title: 'Stock receipt',
      subtitle: 'Baby clothing delivery',
      date: 'Yesterday, 3:20 PM',
      status: 'Received',
      icon: Icons.inventory_2_outlined,
      amount: 24,
      details: 'Sample receipt of incoming baby clothing stock.',
    ),
    const _OperationRecord(
      id: 'TXN-1047',
      type: _ActivityType.sale,
      title: 'Sale #1047',
      subtitle: 'Mobile Money · 2 items',
      date: 'Yesterday, 2:05 PM',
      status: 'Completed',
      icon: Icons.receipt_long_outlined,
      amount: 18.00,
      details: 'Sample sale with two items.',
    ),
    const _OperationRecord(
      id: 'CASH-022',
      type: _ActivityType.cash,
      title: 'Cash in',
      subtitle: 'Additional till float',
      date: 'Yesterday, 8:35 AM',
      status: 'Recorded',
      icon: Icons.arrow_downward_rounded,
      amount: 20.00,
      details: 'Sample cash-in entry.',
    ),
    const _OperationRecord(
      id: 'STOCK-011',
      type: _ActivityType.stock,
      title: 'Stock receipt',
      subtitle: 'Accessories delivery',
      date: '14 Oct, 11:10 AM',
      status: 'Received',
      icon: Icons.inventory_2_outlined,
      amount: 15,
      details: 'Sample receipt of incoming accessories.',
    ),
  ];

  List<_OperationRecord> get _filteredRecords {
    return _records.where((record) {
      switch (_selectedFilter) {
        case 'Shifts':
          return record.type == _ActivityType.shift;
        case 'Cash':
          return record.type == _ActivityType.cash;
        case 'Stock':
          return record.type == _ActivityType.stock;
        case 'Sales':
          return record.type == _ActivityType.sale;
        default:
          return true;
      }
    }).toList();
  }

  int get _salesCount =>
      _records.where((r) => r.type == _ActivityType.sale).length;

  int get _cashMovementCount =>
      _records.where((r) => r.type == _ActivityType.cash).length;

  int get _stockReceiptCount =>
      _records.where((r) => r.type == _ActivityType.stock).length;

  String _money(double amount) => '\$${amount.abs().toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: _operationsBackground,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text(
            'Store operations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monitor shifts, cash, stock and sales activity.',
            style: TextStyle(color: _operationsMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),

          _buildShiftBanner(),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Transactions',
                  value: '$_salesCount',
                  icon: Icons.receipt_long_outlined,
                  color: _operationsBlue,
                  background: const Color(0xFFE8EEFF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Cash entries',
                  value: '$_cashMovementCount',
                  icon: Icons.payments_outlined,
                  color: Colors.teal,
                  background: const Color(0xFFE1F5F1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Stock receipts',
                  value: '$_stockReceiptCount',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF9A6500),
                  background: const Color(0xFFFFF0D9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'Recent activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Shifts', 'Sales', 'Cash', 'Stock'].map((
                filter,
              ) {
                final selected = filter == _selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFE0E9FF),
                    labelStyle: TextStyle(
                      color: selected ? _operationsBlue : _operationsMuted,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          if (records.isEmpty)
            _buildEmptyState()
          else
            ...records.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildRecordCard(record),
              ),
            ),

          const SizedBox(height: 16),

          const Text(
            'Demo records only. These entries are not connected to the '
            'cashier app or a live database.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: _operationsMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _operationsBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.point_of_sale_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cashier shift',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Shift currently open',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sample opening float: \$50.00',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Open',
              style: TextStyle(
                color: _operationsBlue,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            style: const TextStyle(fontSize: 11, color: _operationsMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(_OperationRecord record) {
    final isNegative = record.amount != null && record.amount! < 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showRecordDetails(record),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F7),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(record.icon, color: _operationsBlue, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.subtitle,
                      style: const TextStyle(
                        color: _operationsMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      record.date,
                      style: const TextStyle(
                        color: _operationsMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (record.amount != null)
                    Text(
                      record.type == _ActivityType.stock
                          ? '${record.amount!.toInt()} units'
                          : '${isNegative ? '-' : ''}${_money(record.amount!)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isNegative
                            ? Colors.red.shade700
                            : Colors.black87,
                      ),
                    ),
                  const SizedBox(height: 7),
                  _statusChip(record.status),
                  const SizedBox(height: 5),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: _operationsMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final Color color;

    switch (status) {
      case 'Open':
      case 'Completed':
      case 'Received':
        color = Colors.green.shade700;
        break;
      default:
        color = _operationsBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.filter_list_off_rounded,
            size: 38,
            color: _operationsMuted,
          ),
          SizedBox(height: 12),
          Text(
            'No activity found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Try selecting another category.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _operationsMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(_OperationRecord record) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record.id,
                  style: const TextStyle(color: _operationsMuted, fontSize: 12),
                ),
                const SizedBox(height: 22),
                _detailRow('Type', _typeLabel(record.type)),
                _detailRow('Date', record.date),
                _detailRow('Status', record.status),
                if (record.amount != null)
                  _detailRow(
                    record.type == _ActivityType.stock ? 'Quantity' : 'Amount',
                    record.type == _ActivityType.stock
                        ? '${record.amount!.toInt()} units'
                        : '${record.amount! < 0 ? '-' : ''}${_money(record.amount!)}',
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  record.details,
                  style: const TextStyle(color: _operationsMuted, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _typeLabel(_ActivityType type) {
    switch (type) {
      case _ActivityType.shift:
        return 'Shift';
      case _ActivityType.cash:
        return 'Cash movement';
      case _ActivityType.stock:
        return 'Stock receipt';
      case _ActivityType.sale:
        return 'Sale';
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _operationsMuted, fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
