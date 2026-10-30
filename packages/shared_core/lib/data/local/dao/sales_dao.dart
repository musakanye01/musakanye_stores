import 'package:drift/drift.dart';
import 'package:shared_core/data/local/app_database.dart';
import 'package:shared_core/data/local/tables/catalogue_table.dart';
import 'package:shared_core/data/local/tables/sale_lines_table.dart';
import 'package:shared_core/data/local/tables/sales_table.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [SalesTable, SaleLinesTable, CatalogueTable])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  /// Saves a sale, its lines and stock deductions atomically.
  Future<void> createSaleLocally({
    required SalesTableCompanion sale,
    required List<SaleLinesTableCompanion> lines,
  }) => transaction(() async {
    final saleId = sale.id.value;

    // Prevent duplicate stock deductions on retries.
    final existingSale = await (select(
      salesTable,
    )..where((t) => t.id.equals(saleId))).getSingleOrNull();

    if (existingSale != null) return;

    // Validate all stock before writing anything.
    final stockRows = <String, CatalogueTableData>{};

    for (final line in lines) {
      final variantId = line.variantId.value;
      final quantity = line.quantity.value;

      if (quantity <= 0) {
        throw StateError('Sale quantities must be greater than zero.');
      }

      final stockRow = await (select(
        catalogueTable,
      )..where((t) => t.variantId.equals(variantId))).getSingleOrNull();

      if (stockRow == null) {
        throw StateError(
          'An item is missing from the local catalogue. '
          'Refresh the catalogue before selling.',
        );
      }

      if (stockRow.stockOnHand < quantity) {
        throw StateError(
          'Insufficient cached stock for '
          '${stockRow.productName}.',
        );
      }

      stockRows[variantId] = stockRow;
    }

    // Save the sale header.
    await into(salesTable).insert(sale);

    // Save lines and deduct stock.
    for (final line in lines) {
      await into(saleLinesTable).insert(line);

      final variantId = line.variantId.value;
      final quantity = line.quantity.value;
      final stockRow = stockRows[variantId]!;

      await (update(
        catalogueTable,
      )..where((t) => t.variantId.equals(variantId))).write(
        CatalogueTableCompanion(
          stockOnHand: Value(stockRow.stockOnHand - quantity),
        ),
      );
    }
  });

  /// Returns sales that still need to be pushed to Supabase.
  Future<List<SalesTableData>> getUnsynced() =>
      (select(salesTable)
            ..where((t) => t.synced.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  /// Returns all lines for a given sale.
  Future<List<SaleLinesTableData>> getLinesForSale(String saleId) =>
      (select(saleLinesTable)..where((t) => t.saleId.equals(saleId))).get();

  /// Marks a sale as successfully synced.
  Future<void> markSynced(String saleId) =>
      (update(salesTable)..where((t) => t.id.equals(saleId))).write(
        const SalesTableCompanion(
          synced: Value(true),
          syncError: Value(false),
          syncErrorMessage: Value(null),
        ),
      );

  /// Records a sync failure.
  Future<void> markSyncFailed(String saleId, String errorMessage) =>
      (update(salesTable)..where((t) => t.id.equals(saleId))).write(
        SalesTableCompanion(
          syncError: const Value(true),
          syncErrorMessage: Value(errorMessage),
        ),
      );

  /// Returns recent sales, newest first.
  Future<List<SalesTableData>> getRecent({int limit = 50, int offset = 0}) =>
      (select(salesTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit, offset: offset))
          .get();
}
