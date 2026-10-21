import 'package:flutter/material.dart';
import 'package:owner/ui/operations/owner_operations_view_model.dart';
import 'package:owner/ui/operations/widgets/activity_filter.dart';
import 'package:owner/ui/operations/widgets/activity_filter_chips.dart';
import 'package:owner/ui/operations/widgets/operations_colors.dart';
import 'package:owner/ui/operations/widgets/operations_empty_state.dart';
import 'package:owner/ui/operations/widgets/sale_tile.dart';
import 'package:owner/ui/operations/widgets/shift_banner.dart';
import 'package:owner/ui/operations/widgets/shift_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/util/result.dart';

class OwnerOperationsScreen extends StatefulWidget {
  const OwnerOperationsScreen({super.key});

  @override
  State<OwnerOperationsScreen> createState() => _OwnerOperationsScreenState();
}

class _OwnerOperationsScreenState extends State<OwnerOperationsScreen> {
  ActivityFilter _filter = ActivityFilter.allSales;

  List<SaleHistory> _visibleSales(List<SaleHistory> allSales) {
    final sales = allSales.where(_filter.matchesSale).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sales;
  }

  List<Shift> _sortedShifts(List<Shift> allShifts) {
    return [...allShifts]..sort((a, b) => b.openedAt.compareTo(a.openedAt));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OwnerOperationsViewModel>();

    return ListenableBuilder(
      listenable: Listenable.merge([viewModel.loadSales, viewModel.loadShifts]),
      builder: (context, _) {
        final sales = _filter.showsSales
            ? _visibleSales(viewModel.sales)
            : const <SaleHistory>[];

        final shifts = _filter.showsSales
            ? const <Shift>[]
            : _sortedShifts(viewModel.shifts);

        final isEmpty = sales.isEmpty && shifts.isEmpty;

        final salesFailed = viewModel.loadSales.result is Error<void>;
        final shiftsFailed = viewModel.loadShifts.result is Error<void>;

        final salesError = salesFailed
            ? (viewModel.loadSales.result as Error<void>).error
            : null;

        final shiftsError = shiftsFailed
            ? (viewModel.loadShifts.result as Error<void>).error
            : null;

        final isLoadingSelectedData = _filter.showsSales
            ? viewModel.loadSales.running
            : viewModel.loadShifts.running;

        final selectedDataFailed = _filter.showsSales
            ? salesFailed
            : shiftsFailed;

        final selectedDataError = _filter.showsSales ? salesError : shiftsError;

        final hasLoadedSelectedData = _filter.showsSales
            ? viewModel.loadSales.completed
            : viewModel.loadShifts.completed;

        return Scaffold(
          backgroundColor: OperationsColors.background,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              ShiftBanner(openShift: viewModel.openShift),
              const SizedBox(height: 26),
              const Text(
                'Recent activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ActivityFilterChips(
                selected: _filter,
                onSelected: (filter) {
                  setState(() => _filter = filter);
                },
              ),
              const SizedBox(height: 14),

              if (isLoadingSelectedData && !hasLoadedSelectedData && isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (selectedDataFailed && isEmpty)
                _OperationsErrorState(
                  message: selectedDataError.toString(),
                  onRetry: () {
                    if (_filter.showsSales) {
                      viewModel.loadSales.execute();
                    } else {
                      viewModel.loadShifts.execute();
                    }
                  },
                )
              else if (isEmpty)
                const OperationsEmptyState()
              else ...[
                if (selectedDataFailed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OperationsErrorState(
                      message: selectedDataError.toString(),
                      onRetry: () {
                        if (_filter.showsSales) {
                          viewModel.loadSales.execute();
                        } else {
                          viewModel.loadShifts.execute();
                        }
                      },
                    ),
                  ),
                if (isLoadingSelectedData) const LinearProgressIndicator(),
                for (final sale in sales)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SaleTile(sale: sale),
                  ),
                for (final shift in shifts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ShiftTile(shift: shift),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OperationsErrorState extends StatelessWidget {
  const _OperationsErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 36,
              color: OperationsColors.muted,
            ),
            const SizedBox(height: 10),
            const Text(
              'Could not load activity',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: OperationsColors.muted),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
