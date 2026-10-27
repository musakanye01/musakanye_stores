import 'package:drift/drift.dart';
import 'package:shared_core/data/local/app_database.dart';
import 'package:shared_core/data/local/tables/catalogue_table.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

part 'catalogue_dao.g.dart';

@DriftAccessor(tables: [CatalogueTable])
class CatalogueDao extends DatabaseAccessor<AppDatabase>
    with _$CatalogueDaoMixin {
  CatalogueDao(super.db);

  /// Returns the full cached catalogue, sorted by product name then variant.
  Future<List<CatalogueTableData>> getAll() =>
      (select(catalogueTable)
            ..orderBy([
              (t) => OrderingTerm.asc(t.productName),
              (t) => OrderingTerm.asc(t.variantId),
            ]))
          .get();

  /// Replaces the entire catalogue cache in a single transaction.
  Future<void> upsertAll(List<CatalogueTableCompanion> rows) =>
      transaction(() async {
        for (final row in rows) {
          await into(catalogueTable).insertOnConflictUpdate(row);
        }
      });

  /// Decrements stock for [variantId] by [quantity] (optimistic local update).
  Future<void> decrementStock(String variantId, int quantity) async {
    final row = await (select(catalogueTable)
          ..where((t) => t.variantId.equals(variantId)))
        .getSingleOrNull();
    if (row == null) return;
    final newStock = (row.stockOnHand - quantity).clamp(0, row.stockOnHand);
    await (update(catalogueTable)
          ..where((t) => t.variantId.equals(variantId)))
        .write(CatalogueTableCompanion(stockOnHand: Value(newStock)));
  }

  /// Converts a Drift row to the domain [CatalogueItem] model.
  static CatalogueItem toDomain(CatalogueTableData row) => CatalogueItem(
    variantId: row.variantId,
    productId: row.productId,
    productName: row.productName,
    categoryName: row.categoryName,
    categoryId: row.categoryId,
    sku: row.sku,
    size: row.size,
    colour: row.colour,
    description: row.description,
    priceCents: row.priceCents,
    stockOnHand: row.stockOnHand,
  );

  /// Converts a [CatalogueItem] to a Drift companion for upsert.
  static CatalogueTableCompanion fromDomain(CatalogueItem item) =>
      CatalogueTableCompanion(
        variantId: Value(item.variantId),
        productId: Value(item.productId),
        productName: Value(item.productName),
        categoryName: Value(item.categoryName),
        categoryId: Value(item.categoryId),
        sku: Value(item.sku),
        size: Value(item.size),
        colour: Value(item.colour),
        description: Value(item.description),
        priceCents: Value(item.priceCents),
        stockOnHand: Value(item.stockOnHand),
        cachedAt: Value(DateTime.now().toUtc()),
      );
}
