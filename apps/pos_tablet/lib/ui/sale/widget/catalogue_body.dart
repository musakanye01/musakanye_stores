import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sale/viewmodel/catalogue_view_model.dart';
import 'package:pos_tablet/ui/sale/widget/product_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

/// Catalogue grid and its empty/loading/error states.
///
/// Uses context.select so it rebuilds only when the values it needs change.
class CatalogueBody extends StatelessWidget {
  const CatalogueBody({super.key, required this.onAdd});

  final ValueChanged<CatalogueItem> onAdd;

  // Card height at 1.0x text scale. Increased from 200: the new card layout
  // (icon + name row, variant, description, chip, price) overflowed.
  static const double _cardExtent = 224;

  @override
  Widget build(BuildContext context) {
    final hasLoaded = context.select((CatalogueViewModel vm) => vm.hasLoaded);
    final hasError = context.select(
      (CatalogueViewModel vm) => vm.error != null && vm.items.isEmpty,
    );
    final isCatalogueEmpty = context.select(
      (CatalogueViewModel vm) => vm.isCatalogueEmpty,
    );

    // NOTE: select compares with ==. This works because filteredItems returns
    // a new list when the filter/catalogue changes. If your view model ever
    // mutates one list in place, return a fresh/unmodifiable copy instead.
    final items = context.select((CatalogueViewModel vm) => vm.filteredItems);

    if (!hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return const Center(
        child: Text('Could not read the product list from this device.'),
      );
    }

    if (isCatalogueEmpty) {
      return const Center(
        child: Text(
          'No products yet. Connect to the internet once to download the catalogue.',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    // Grow the card with the user's text scale (capped) so larger system
    // fonts don't overflow the fixed-height cells.
    final textScale = MediaQuery.textScalerOf(context)
        .scale(1)
        .clamp(1.0, 1.4)
        .toDouble();

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: _cardExtent * textScale,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ProductTile(
          key: ValueKey(item.variantId),
          item: item,
          onAdd: onAdd,
        );
      },
    );
  }
}
