import 'package:flutter/material.dart';
import 'package:owner/ui/operations/sales_trend_chart.dart';
import 'package:shared_core/theme/app_colors.dart';

class SalesTrendCard extends StatelessWidget {
  const SalesTrendCard({super.key, required this.label, required this.points});

  final String label;
  final List<SalesTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sales performance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                // Flexible lets the long label wrap on narrow phones.
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SalesTrendChart(points: points),
          ],
        ),
      ),
    );
  }
}
