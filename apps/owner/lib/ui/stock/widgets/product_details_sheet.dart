import 'package:flutter/material.dart';
import 'package:owner/ui/stock/inventory_view_model.dart';
import 'package:owner/ui/stock/widgets/format_money.dart';
import 'package:owner/ui/stock/widgets/inventory_colors.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

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
    final lowStock =
        product.stockOnHand <= InventoryViewModel.lowStockThreshold;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        decoration: const BoxDecoration(
          color: InventoryColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.displayName,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              product.categoryName ?? 'Uncategorised',
              style: const TextStyle(color: InventoryColors.muted),
            ),
            const SizedBox(height: 24),
            _DetailRow('Selling price', formatMoney(product.price)),
            _DetailRow('Quantity in stock', '${product.stockOnHand} units'),
            if (product.sku?.isNotEmpty == true)
              _DetailRow('SKU', product.sku!),
            if (product.size?.isNotEmpty == true)
              _DetailRow('Size', product.size!),
            if (product.colour?.isNotEmpty == true)
              _DetailRow('Colour', product.colour!),
            _DetailRow(
              'Stock status',
              lowStock ? 'Low stock' : 'In stock',
              valueColor: lowStock ? InventoryColors.lowStock : Colors.green,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onEdit();
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: InventoryColors.muted),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
