import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sale/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/sale/widget/product_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

/// One grid cell. It selects only its own cart quantity, so adding an item to
/// the cart rebuilds that single card rather than the whole grid/screen.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.item, required this.onAdd});

  final CatalogueItem item;
  final ValueChanged<CatalogueItem> onAdd;

  @override
  Widget build(BuildContext context) {
    final inCart = context.select(
      (CartViewModel cart) => cart.quantityOf(item.variantId),
    );

    return ProductCard(
      item: item,
      remainingStock: item.stockOnHand - inCart,
      onAdd: () => onAdd(item),
    );
  }
}
