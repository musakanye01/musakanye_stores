import 'package:drift/drift.dart';

/// Local table for completed sales (header).
class SalesTable extends Table {
  @override
  String get tableName => 'sales';

  TextColumn get id => text()();
  TextColumn get shiftId => text()();
  TextColumn get paymentMethod => text()(); // 'cash' | 'ecocash_usd'
  IntColumn get totalCents => integer()();
  IntColumn get tenderedCents => integer()();
  TextColumn get idempotencyKey => text()();
  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get syncError => boolean().withDefault(const Constant(false))();
  TextColumn get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
