import 'package:flutter/material.dart';
import 'package:owner/ui/operations/widgets/format_helpers.dart';
import 'package:owner/ui/operations/widgets/operations_colors.dart';
import 'package:shared_core/domain/model/shift.dart';

/// Blue banner for the currently open cashier shift, or a "no shift" state.
class ShiftBanner extends StatelessWidget {
  const ShiftBanner({super.key, required this.openShift});

  final Shift? openShift;

  @override
  Widget build(BuildContext context) {
    final shift = openShift;
    final isOpen = shift != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: OperationsColors.primary,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cashier shift',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  isOpen ? 'Shift currently open' : 'No shift open',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (shift != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Opening float: ${formatCents(shift.openingFloatCents)}'
                    ' · since ${formatTime(shift.openedAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOpen ? 'Open' : 'Closed',
              style: const TextStyle(
                color: OperationsColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
