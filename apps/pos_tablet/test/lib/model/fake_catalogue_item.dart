import 'package:shared_core/domain/model/catalogue_item.dart';

CatalogueItem fakeCatalogueItem(String id, String name, {int stock = 5}) =>
    CatalogueItem(
      variantId: id,
      productId: 'p-$id',
      productName: name,
      categoryName: 'Tops',
      sku: 'SKU-$id',
      size: 'M',
      colour: 'Blue',
      priceCents: 500,
      stockOnHand: stock,
      description: '',
      categoryId: 'cat-1',
    );
