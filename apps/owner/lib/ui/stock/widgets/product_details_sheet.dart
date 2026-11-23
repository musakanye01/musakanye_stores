import 'package:flutter/material.dart';
import 'package:owner/ui/stock/inventory_view_model.dart';
import 'package:owner/ui/stock/widgets/format_money.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/theme/app_colors.dart';

class ProductDetailsSheet extends StatelessWidget {
  const ProductDetailsSheet({
    super.key,
    required this.product,
    required this.onEdit,
  });

  final CatalogueItem product;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final stock = product.stockOnHand;
    final isOutOfStock = stock == 0;
    final isLowStock =
        stock > 0 && stock <= InventoryViewModel.lowStockThreshold;

    final statusLabel = isOutOfStock
        ? 'Out of stock'
        : isLowStock
        ? 'Low stock'
        : 'In stock';

    final statusColor = isOutOfStock
        ? AppColors.danger
        : isLowStock
        ? AppColors.warning
        : AppColors.success;

    final statusBackground = isOutOfStock
        ? AppColors.danger.withValues(alpha: 0.09)
        : isLowStock
        ? AppColors.warning.withValues(alpha: 0.12)
        : AppColors.success.withValues(alpha: 0.09);

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Product heading
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.displayName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.heading,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.categoryName ?? 'Uncategorised',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Key metrics
              Row(
                children: [
                  Expanded(
                    child: _MetricPanel(
                      label: 'Selling price',
                      value: formatMoney(product.price),
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricPanel(
                      label: 'Available units',
                      value: '$stock',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Product information
              Text(
                'Product information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 12),
              if (product.sku?.isNotEmpty == true)
                _InfoRow(label: 'SKU', value: product.sku!),
              if (product.size?.isNotEmpty == true)
                _InfoRow(label: 'Size', value: product.size!),
              if (product.colour?.isNotEmpty == true)
                _InfoRow(label: 'Colour', value: product.colour!),

              const SizedBox(height: 18),
              const Divider(color: AppColors.outline, height: 1),
              const SizedBox(height: 20),

              // Edit action
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit product'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
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

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.heading,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.heading,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
