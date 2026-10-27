import 'package:drift/drift.dart';
import 'package:shared_core/data/local/app_database.dart';
import 'package:shared_core/data/local/tables/sale_lines_table.dart';
import 'package:shared_core/data/local/tables/sales_table.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [SalesTable, SaleLinesTable])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  /// Inserts a sale header and its line items in a single transaction.
  Future<void> insertSaleWithLines({
    required SalesTableCompanion sale,
    required List<SaleLinesTableCompanion> lines,
  }) =>
      transaction(() async {
        await into(salesTable).insertOnConflictUpdate(sale);
        for (final line in lines) {
          await into(saleLinesTable).insertOnConflictUpdate(line);
        }
      });

  /// Returns sale + lines that still need to be pushed to Supabase.
  Future<List<SalesTableData>> getUnsynced() =>
      (select(salesTable)..where((t) => t.synced.equals(false))).get();

  /// Returns all lines for a given sale.
  Future<List<SaleLinesTableData>> getLinesForSale(String saleId) =>
      (select(saleLinesTable)..where((t) => t.saleId.equals(saleId))).get();

  /// Marks a sale (and its lines are immutable so no separate mark needed)
  /// as successfully synced.
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

  /// Returns the [limit] most recent sales, ordered newest-first.
  Future<List<SalesTableData>> getRecent({int limit = 50, int offset = 0}) =>
      (select(salesTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit, offset: offset))
          .get();
}
