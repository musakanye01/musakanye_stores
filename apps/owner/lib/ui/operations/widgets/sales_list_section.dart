import 'package:flutter/material.dart';
import 'package:owner/ui/operations/widgets/operations_empty_state.dart';
import 'package:owner/ui/operations/widgets/sale_tile.dart';
import 'package:owner/ui/operations/widgets/sales_error_state.dart';
import 'package:shared_core/domain/model/sale_history.dart';

/// Loading, error, empty and list states for the sales list.
class SalesListSection extends StatelessWidget {
  const SalesListSection({
    super.key,
    required this.sales,
    required this.hasCachedSales,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  /// Sales left after period, filter and search are applied.
  final List<SaleHistory> sales;

  /// Whether any sales are loaded at all, before filtering.
  final bool hasCachedSales;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = errorMessage;

    if (!hasCachedSales) {
      if (isLoading) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (message != null) {
        return SalesErrorState(message: message, onRetry: onRetry);
      }
    }

    // A failed or running refresh stays visible even if filters match nothing.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null)
          SalesErrorState(message: message, onRetry: onRetry),
        if (isLoading) const LinearProgressIndicator(),
        if (sales.isEmpty)
          const OperationsEmptyState()
        else
          for (final sale in sales)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SaleTile(sale: sale),
            ),
      ],
    );
  }
}
