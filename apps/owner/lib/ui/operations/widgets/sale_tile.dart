import 'package:flutter/material.dart';

import 'package:owner/ui/operations/widgets/activity_details_sheet.dart';
import 'package:owner/ui/operations/widgets/activity_filter.dart';
import 'package:owner/ui/operations/widgets/activity_tile.dart';
import 'package:owner/ui/operations/widgets/format_helpers.dart';
import 'package:shared_core/domain/model/sale_history.dart';

class SaleTile extends StatelessWidget {
  const SaleTile({super.key, required this.sale});

  final SaleHistory sale;

  String get _shortId => sale.id.length <= 8
      ? sale.id.toUpperCase()
      : sale.id.substring(0, 8).toUpperCase();

  String get _paymentLabel {
    switch (normalisePaymentMethod(sale.paymentMethod)) {
      case 'cash':
        return 'Cash';
      case 'ecocash':
        return 'Ecocash';
      default:
        return sale.paymentMethod;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActivityTile(
      icon: Icons.receipt_long_outlined,
      title: 'Sale #$_shortId',
      subtitle: _paymentLabel,
      date: formatActivityDate(sale.createdAt),
      status: capitalise(sale.status),
      amount: formatCents(sale.totalCents),
      onTap: () {
        final itemRows = <DetailRow>[];

        for (final item in sale.items) {
          final variant = item.variantDescription?.trim();

          final itemName = variant == null || variant.isEmpty
              ? item.productName
              : '${item.productName} — $variant';

          itemRows.add((
            itemName,
            '${item.quantity} × ${formatCents(item.unitPriceCents)}'
                ' = ${formatCents(item.lineTotalCents)}',
          ));
        }

        showActivityDetails(
          context,
          title: 'Sale details',
          id: sale.id,
          rows: [
            ('Type', normalisePaymentMethod(sale.paymentMethod)),
            // Keep your existing Date row here.
            ('Status', sale.status),
            ('Amount', formatCents(sale.totalCents)),
            if (itemRows.isNotEmpty) ('Items sold', ''),
            ...itemRows,
          ],
        );
      },
    );
  }
}
