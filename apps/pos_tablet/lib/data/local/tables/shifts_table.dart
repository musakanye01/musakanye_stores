import 'package:drift/drift.dart';

/// Local table for shifts.
/// [synced] = false means the row hasn't been pushed to Supabase yet.
/// [syncError] = true means the last sync attempt for this row failed.
class ShiftsTable extends Table {
  @override
  String get tableName => 'shifts';

  TextColumn get id => text()();
  TextColumn get cashierId => text()();
  TextColumn get status => text()(); // 'open' | 'closed'
  IntColumn get openingFloatCents => integer()();
  IntColumn get closingCountedCents => integer().nullable()();
  TextColumn get closingNote => text().nullable()();
  TextColumn get idempotencyKey => text()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  BoolColumn get syncError => boolean().withDefault(const Constant(false))();
  TextColumn get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
