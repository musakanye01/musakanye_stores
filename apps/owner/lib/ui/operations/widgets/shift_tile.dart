import 'package:flutter/material.dart';
import 'package:owner/ui/operations/widgets/activity_details_sheet.dart';
import 'package:owner/ui/operations/widgets/activity_tile.dart';
import 'package:owner/ui/operations/widgets/format_helpers.dart';
import 'package:shared_core/domain/model/shift.dart';

class ShiftTile extends StatelessWidget {
  const ShiftTile({super.key, required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context) {
    return ActivityTile(
      icon: Icons.point_of_sale_outlined,
      title: 'Cashier shift',
      subtitle: 'Opening float: ${formatCents(shift.openingFloatCents)}',
      date: formatActivityDate(shift.openedAt),
      status: capitalise(shift.status),
      amount: formatCents(shift.openingFloatCents),
      onTap: () => showActivityDetails(
        context,
        title: 'Cashier shift',
        id: shift.id,
        rows: [
          ('Type', 'Shift'),
          ('Opened', formatActivityDate(shift.openedAt)),
          ('Status', capitalise(shift.status)),
          ('Opening float', formatCents(shift.openingFloatCents)),
          if (shift.deviceId != null) ('Device', shift.deviceId!),
        ],
      ),
    );
  }
}
