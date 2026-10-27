import 'package:drift/drift.dart';
import 'package:shared_core/data/local/app_database.dart';
import 'package:shared_core/data/local/tables/stock_receipts_table.dart';

part 'stock_receipts_dao.g.dart';

@DriftAccessor(tables: [StockReceiptsTable])
class StockReceiptsDao extends DatabaseAccessor<AppDatabase>
    with _$StockReceiptsDaoMixin {
  StockReceiptsDao(super.db);

  /// Inserts a new stock receipt (unsynced by default).
  Future<void> insert(StockReceiptsTableCompanion row) =>
      into(stockReceiptsTable).insertOnConflictUpdate(row);

  /// Returns all rows pending sync.
  Future<List<StockReceiptsTableData>> getUnsynced() =>
      (select(stockReceiptsTable)
            ..where((t) => t.synced.equals(false)))
          .get();

  /// Returns recent receipts, newest-first.
  Future<List<StockReceiptsTableData>> getRecent({int limit = 50}) =>
      (select(stockReceiptsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  /// Marks a receipt as successfully synced.
  Future<void> markSynced(String id) =>
      (update(stockReceiptsTable)..where((t) => t.id.equals(id))).write(
        const StockReceiptsTableCompanion(
          synced: Value(true),
          syncError: Value(false),
          syncErrorMessage: Value(null),
        ),
      );

  /// Records a sync failure.
  Future<void> markSyncFailed(String id, String errorMessage) =>
      (update(stockReceiptsTable)..where((t) => t.id.equals(id))).write(
        StockReceiptsTableCompanion(
          syncError: const Value(true),
          syncErrorMessage: Value(errorMessage),
        ),
      );
}
