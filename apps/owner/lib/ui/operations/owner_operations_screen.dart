import 'package:flutter/material.dart';
import 'package:owner/ui/operations/owner_operations_view_model.dart';
import 'package:owner/ui/operations/sales_calculations.dart';
import 'package:owner/ui/operations/sales_period.dart';
import 'package:owner/ui/operations/widgets/activity_filter.dart';
import 'package:owner/ui/operations/widgets/activity_filter_chips.dart';
import 'package:owner/ui/operations/widgets/sales_list_section.dart';
import 'package:owner/ui/operations/widgets/sales_metrics_row.dart';
import 'package:owner/ui/operations/widgets/sales_period_selector.dart';
import 'package:owner/ui/operations/widgets/sales_search_field.dart';
import 'package:owner/ui/operations/widgets/sales_trend_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/theme/app_colors.dart';
import 'package:shared_core/util/result.dart';

class OwnerOperationsScreen extends StatefulWidget {
  const OwnerOperationsScreen({super.key});

  @override
  State<OwnerOperationsScreen> createState() => _OwnerOperationsScreenState();
}

class _OwnerOperationsScreenState extends State<OwnerOperationsScreen> {
  final TextEditingController _searchController = TextEditingController();

  SalesPeriod _period = SalesPeriod.today;
  ActivityFilter _filter = ActivityFilter.allSales;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<OwnerOperationsViewModel>();

    return ListenableBuilder(
      listenable: viewModel.loadSales,
      builder: (context, _) {
        // One timestamp, so the list and chart agree on what "today" is.
        final now = DateTime.now();

        final periodSales = salesForPeriod(viewModel.sales, _period, now);
        final completed = completedSales(periodSales);
        final visible = visibleSales(periodSales, _filter, _searchQuery);

        final result = viewModel.loadSales.result;
        final errorMessage = result is Error<void>
            ? result.error.toString()
            : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Text(
                    'Revenue and transaction activity',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  SalesPeriodSelector(
                    selected: _period,
                    onChanged: (period) => setState(() => _period = period),
                  ),
                  const SizedBox(height: 16),
                  SalesMetricsRow(
                    totalCents: totalSalesCents(completed),
                    transactionCount: completed.length,
                  ),
                  const SizedBox(height: 18),
                  SalesTrendCard(
                    label: _period.trendLabel,
                    points: buildTrendPoints(completed, _period, now),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent sales',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        visible.length == 1
                            ? '1 transaction'
                            : '${visible.length} transactions',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SalesSearchField(
                    controller: _searchController,
                    query: _searchQuery,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    onClear: _clearSearch,
                  ),
                  const SizedBox(height: 12),
                  ActivityFilterChips(
                    selected: _filter,
                    onSelected: (filter) => setState(() => _filter = filter),
                  ),
                  const SizedBox(height: 14),
                  SalesListSection(
                    sales: visible,
                    hasCachedSales: viewModel.sales.isNotEmpty,
                    isLoading: viewModel.loadSales.running,
                    errorMessage: errorMessage,
                    onRetry: () => viewModel.loadSales.execute(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
