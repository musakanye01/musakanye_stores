import 'package:flutter/material.dart';

import 'package:owner/ui/dashboard/dashboard_view_model.dart';
import 'package:owner/ui/dashboard/widgets/dashboard_colors.dart';
import 'package:owner/ui/dashboard/widgets/fast_movers_section.dart';
import 'package:owner/ui/dashboard/widgets/metric_card.dart';
import 'package:owner/ui/dashboard/widgets/sales_trend_chart.dart';
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
    final theme = Theme.of(context);

    final lowStock = [
      for (final item in summary.lowStockItems)
        LowStockItem(
          name: item.displayName,
          category: item.categoryName ?? 'Uncategorised',
          stock: item.stockOnHand,
        ),
    ];

    final metrics = [
      MetricCard(
        title: 'Sales This Week',
        value: _formatCents(summary.weekCents),
        subtitle: 'Since Monday',
        icon: Icons.calendar_view_week_outlined,
        iconColor: DashboardColors.primary,
        backgroundColor: DashboardColors.primaryTint,
        trailingIcon: summary.weekCents >= 0
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded,
        trailingIconColor: const Color(0xFF16834A),
        onTap: onOpenSales,
      ),
      MetricCard(
        title: 'Transactions Today',
        value: '${summary.todayTransactionCount}',
        subtitle: 'Completed sales',
        icon: Icons.receipt_long_outlined,
        iconColor: theme.colorScheme.primary,
        backgroundColor: DashboardColors.primaryTint,
        onTap: onOpenSales,
      ),
      MetricCard(
        title: 'Average Spend',
        value: _formatCents(summary.averageSpendCents),
        subtitle: 'Per transaction today',
        icon: Icons.payments_outlined,
        iconColor: const Color(0xFF16834A),
        backgroundColor: const Color(0xFFE7F5EC),
        onTap: onOpenSales,
      ),
      MetricCard(
        title: 'Open Shifts',
        value: '${summary.openShiftCount}',
        subtitle: 'Currently active',
        icon: Icons.schedule_outlined,
        iconColor: DashboardColors.warning,
        backgroundColor: DashboardColors.warningTint,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'Here is how your store is doing today.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (refreshFailed) ...[
              const SizedBox(height: 8),
              Text(
                "Couldn't refresh. Showing the last loaded data.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 22),

            _SalesTodayCard(
              amount: _formatCents(summary.todayCents),
              transactions: summary.todayTransactionCount,
              onTap: onOpenSales,
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 360
                    ? 1
                    : (constraints.maxWidth / 250).floor().clamp(2, 4);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: metrics.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 174,
                  ),
                  itemBuilder: (context, index) => metrics[index],
                );
              },
            ),

            const SizedBox(height: 24),

            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SalesTrendChart(points: summary.salesTrend),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FastMoversSection(
                      products: summary.fastMovingProducts,
                    ),
                  ),
                ],
              )
            else ...[
              SalesTrendChart(points: summary.salesTrend),
              const SizedBox(height: 16),
              FastMoversSection(products: summary.fastMovingProducts),
            ],
            const SizedBox(height: 24),

            StockAlertsSection(items: lowStock, onViewInventory: onOpenStock),
          ],
        );
      },
    );
  }
}

class _SalesTodayCard extends StatelessWidget {
  const _SalesTodayCard({
    required this.amount,
    required this.transactions,
    required this.onTap,
  });

  final String amount;
  final int transactions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.point_of_sale_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Sales Today',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '$transactions completed ${transactions == 1 ? 'transaction' : 'transactions'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              "Couldn't load the dashboard",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
