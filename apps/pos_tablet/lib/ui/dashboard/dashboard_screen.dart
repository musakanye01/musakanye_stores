import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/dashboard/widget/dashboard_metric_card.dart';
import 'package:pos_tablet/ui/dashboard/widget/dashboard_header.dart';
import 'package:pos_tablet/ui/dashboard/widget/dashboard_primary_action.dart';
import 'package:pos_tablet/ui/dashboard/widget/dashboard_quick_actions.dart';
import 'package:pos_tablet/ui/dashboard/widget/dashboard_sync_status.dart';
import 'package:provider/provider.dart';

import 'package:pos_tablet/ui/shared/tablet_scaffold.dart';
import 'package:pos_tablet/ui/shifts/shift_summary_view_model.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:shared_core/domain/model/shift_sales_summary.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = context.select<ShiftSummaryViewModel, ShiftSalesSummary>(
      (vm) => vm.summary,
    );

    final shiftState = context.select<ShiftViewModel, ShiftState>(
      (vm) => vm.state,
    );

    final cashSales = summary.cashSalesCents;
    final ecoCashSales = summary.ecoCashSalesCents;
    final totalSales = cashSales + ecoCashSales;

    return TabletScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16 : 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeader(shiftState: shiftState),
                    const SizedBox(height: 28),

                    DashboardPrimaryAction(
                      onTap: () => context.goNamed('sales'),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Shift overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, metricConstraints) {
                        final columns = metricConstraints.maxWidth >= 1000
                            ? 4
                            : metricConstraints.maxWidth >= 600
                            ? 2
                            : 1;

                        final spacing = 16.0;
                        final width =
                            (metricConstraints.maxWidth -
                                spacing * (columns - 1)) /
                            columns;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            DashboardMetricCard(
                              width: width,
                              label: 'Total sales',
                              value: _formatMoney(totalSales),
                              icon: Icons.payments_outlined,
                              isPrimary: true,
                              trendIcon: Icons.trending_up,
                            ),
                            DashboardMetricCard(
                              width: width,
                              label: 'Transactions',
                              value: summary.salesCount.toString(),
                              icon: Icons.receipt_long_outlined,
                            ),
                            DashboardMetricCard(
                              width: width,
                              label: 'Cash sales',
                              value: _formatMoney(cashSales),
                              icon: Icons.money_outlined,
                            ),
                            DashboardMetricCard(
                              width: width,
                              label: 'EcoCash sales',
                              value: _formatMoney(ecoCashSales),
                              icon: Icons.phone_android_outlined,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    const DashboardSyncStatus(),
                    const SizedBox(height: 28),

                    Text(
                      'Quick access',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    DashboardQuickActions(
                      onSaleHistory: () => context.goNamed('sales-history'),
                      onShift: () => context.goNamed('shift'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatMoney(int cents) {
    return '\$${(cents / 100).toStringAsFixed(2)}';
  }
}
