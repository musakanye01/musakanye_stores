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
      onTap: () => showActivityDetails(
        context,
        title: 'Sale #$_shortId',
        id: sale.id,
        rows: [
          ('Type', '$_paymentLabel sale'),
          ('Date', formatActivityDate(sale.createdAt)),
          ('Status', capitalise(sale.status)),
          ('Amount', formatCents(sale.totalCents)),
        ],
      ),
    );
  }
}
