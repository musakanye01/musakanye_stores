import 'package:flutter/material.dart';
import 'package:owner/ui/stock/inventory_view_model.dart';
import 'package:owner/ui/stock/widgets/format_money.dart';
import 'package:owner/ui/stock/widgets/inventory_colors.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final CatalogueItem product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lowStock =
        product.stockOnHand <= InventoryViewModel.lowStockThreshold;
    final category = product.categoryName ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 58,
                decoration: BoxDecoration(
                  color: InventoryColors.surfaceTint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _categoryIcon(category),
                  size: 25,
                  color: InventoryColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category.isEmpty ? 'Uncategorised' : category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: InventoryColors.muted,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          '${product.stockOnHand} in stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: lowStock
                                ? InventoryColors.lowStock
                                : InventoryColors.muted,
                          ),
                        ),
                        if (lowStock) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 15,
                            color: InventoryColors.lowStock,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: InventoryColors.muted,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Clothing':
      return Icons.checkroom_outlined;
    case 'Accessories':
      return Icons.child_care_outlined;
    case 'Footwear':
      return Icons.roller_shades_closed_sharp;
    case 'Feeding':
      return Icons.baby_changing_station_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}
