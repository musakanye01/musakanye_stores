import 'package:flutter/material.dart';
import 'package:owner/ui/operations/widgets/format_helpers.dart';
import 'package:shared_core/theme/app_colors.dart';

class SalesMetricsRow extends StatelessWidget {
  const SalesMetricsRow({
    super.key,
    required this.totalCents,
    required this.transactionCount,
  });

  final int totalCents;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    final averageCents =
        transactionCount == 0 ? 0 : totalCents ~/ transactionCount;

    return Row(
      children: [
        Expanded(
          child: _SalesMetricCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total sales',
            value: formatCents(totalCents),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SalesMetricCard(
            icon: Icons.receipt_long_outlined,
            label: 'Transactions',
            value: '$transactionCount',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SalesMetricCard(
            icon: Icons.trending_up_rounded,
            label: 'Average sale',
            value: formatCents(averageCents),
          ),
        ),
      ],
    );
  }
}

class _SalesMetricCard extends StatelessWidget {
  const _SalesMetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.heading,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
