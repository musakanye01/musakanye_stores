import 'package:drift/drift.dart';

/// Stock receipt records written offline, synced later.
class StockReceiptsTable extends Table {
  @override
  String get tableName => 'stock_receipts';

  TextColumn get id => text()();
  TextColumn get variantId => text()();
  IntColumn get quantity => integer()();
  TextColumn get note => text()();
  TextColumn get reference => text().nullable()();
  TextColumn get idempotencyKey => text()();
  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get syncError => boolean().withDefault(const Constant(false))();
  TextColumn get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
