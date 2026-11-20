import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/checkout/widget/payment_method.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:pos_tablet/ui/shared/sync_badge.dart';
// Adjust this path if SaleHistory lives elsewhere in shared_core.
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/sale_line_item.dart';

/// Read-only summary of one past sale.
///
/// Top: receipt id + time, sync badge, chevron.
/// Middle: a preview of the first few line items.
/// Bottom: payment/status pills on the left, the sale total on the right.
/// Tapping opens the receipt (handled by [onTap]).
///
/// Styled like the cart summary bar: surfaceContainerLow, 18dp radius,
/// 44dp primaryContainer icon tile.
class SaleHistoryTile extends StatelessWidget {
  const SaleHistoryTile({super.key, required this.sale, required this.onTap});

  final SaleHistory sale;
  final VoidCallback onTap;

  /// How many line items to preview before collapsing the rest into
  /// "+N more".
  static const int _previewLines = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = MaterialLocalizations.of(context);

    final created = sale.createdAt.toLocal();
    final when =
        '${l10n.formatMediumDate(created)} · '
        '${l10n.formatTimeOfDay(TimeOfDay.fromDateTime(created), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';

    final shortId = sale.id.length > 8 ? sale.id.substring(0, 8) : sale.id;

    // Total units sold (matches the cart's "N items" wording).
    final itemCount = sale.items.fold<int>(0, (sum, i) => sum + i.quantity);
    final previewItems = sale.items.take(_previewLines).toList();
    final hiddenLines = sale.items.length - previewItems.length;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt id + time, sync badge, chevron.
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${shortId.toUpperCase()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                when,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SyncBadge(sale.syncStatus),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),

                    // Line item preview (read-only).
                    if (previewItems.isNotEmpty) ...[
                      Divider(height: 24, color: colors.outlineVariant),
                      for (var i = 0; i < previewItems.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _ItemLine(item: previewItems[i]),
                      ],
                      if (hiddenLines > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '+$hiddenLines more ${hiddenLines == 1 ? 'item' : 'items'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ] else
                      const SizedBox(height: 12),

                    // Pills on the left, total on the bottom right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaPill(
                                icon: _paymentIcon(sale.paymentMethod),
                                label: _paymentLabel(sale.paymentMethod),
                              ),
                              if (itemCount > 0)
                                _MetaPill(
                                  icon: Icons.shopping_bag_outlined,
                                  label:
                                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                                ),
                              _MetaPill(
                                icon: Icons.check_circle_outline,
                                label: _capitalize(sale.status),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatUsd(sale.totalCents),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static PaymentMethod? _method(String apiValue) {
    for (final method in PaymentMethod.values) {
      if (method.apiValue == apiValue) return method;
    }
    return null;
  }

  static String _paymentLabel(String apiValue) =>
      _method(apiValue)?.label ?? apiValue;

  static IconData _paymentIcon(String apiValue) =>
      _method(apiValue)?.icon ?? Icons.payments_outlined;

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

/// Small read-only tag (icon + label) used for sale metadata.
class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One line of the sale: product (and variant) on the left, line total and
/// "qty × unit price" on the right. Same information as a cart line, with no
/// controls.
class _ItemLine extends StatelessWidget {
  const _ItemLine({required this.item});

  final SaleLineItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final variant = item.variantDescription?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (variant != null && variant.isNotEmpty)
                Text(
                  variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatUsd(item.lineTotalCents),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${item.quantity} × ${formatUsd(item.unitPriceCents)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
