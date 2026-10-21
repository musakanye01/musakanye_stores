import 'package:flutter/material.dart';

import 'package:owner/ui/dashboard/dashboard_view_model.dart';
import 'package:owner/ui/dashboard/widgets/all_time_sales_card.dart';
import 'package:owner/ui/dashboard/widgets/dashboard_colors.dart';
import 'package:owner/ui/dashboard/widgets/metric_card.dart';
import 'package:owner/ui/dashboard/widgets/stock_alerts_section.dart';
import 'package:shared_core/domain/model/dashboard_summary.dart';

String _formatCents(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

class DashboardHome extends StatelessWidget {
  const DashboardHome({
    super.key,
    required this.viewModel,
    required this.onOpenSales,
    required this.onOpenStock,
  });

  final DashboardViewModel viewModel;
  final VoidCallback onOpenSales;
  final VoidCallback onOpenStock;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, viewModel.load]),
      builder: (context, _) {
        final summary = viewModel.summary;

        // First load: nothing to show yet.
        if (summary == null) {
          if (viewModel.load.error) {
            return _ErrorView(onRetry: viewModel.load.execute);
          }
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: viewModel.load.execute,
          child: _Content(
            summary: summary,
            refreshFailed: viewModel.load.error,
            onOpenSales: onOpenSales,
            onOpenStock: onOpenStock,
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.summary,
    required this.refreshFailed,
    required this.onOpenSales,
    required this.onOpenStock,
  });

  final DashboardSummary summary;
  final bool refreshFailed;
  final VoidCallback onOpenSales;
  final VoidCallback onOpenStock;

  @override
  Widget build(BuildContext context) {
    final lowStock = [
      for (final item in summary.lowStockItems)
        LowStockItem(
          name: item.displayName,
          category: item.categoryName ?? 'Uncategorised',
          stock: item.stockOnHand,
        ),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const SizedBox(height: 6),
        const Text(
          'Here is how your store is doing today.',
          style: TextStyle(color: DashboardColors.muted, fontSize: 14),
        ),
        if (refreshFailed) ...[
          const SizedBox(height: 8),
          const Text(
            "Couldn't refresh. Showing the last loaded data.",
            style: TextStyle(color: DashboardColors.warning, fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        AllTimeSalesCard(
          amount: _formatCents(summary.allTimeCents),
          onTap: onOpenSales,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: "Today's sales",
                value: _formatCents(summary.todayCents),
                subtitle: 'Today',
                icon: Icons.receipt_long_outlined,
                iconColor: DashboardColors.primary,
                backgroundColor: DashboardColors.primaryTint,
                onTap: onOpenSales,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Low Stock',
                value: '${summary.lowStockCount}',
                subtitle: 'Needs attention',
                icon: Icons.warning_amber_rounded,
                iconColor: DashboardColors.warning,
                backgroundColor: DashboardColors.warningTint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        StockAlertsSection(items: lowStock, onViewInventory: onOpenStock),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: DashboardColors.muted,
            ),
            const SizedBox(height: 12),
            const Text(
              "Couldn't load the dashboard",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
