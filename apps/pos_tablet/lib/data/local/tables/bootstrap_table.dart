import 'package:drift/drift.dart';

class BootstrapState extends Table {
  IntColumn get id => integer()();

  DateTimeColumn get completedAt => dateTime().nullable()();

  DateTimeColumn get lastRefreshAt => dateTime().nullable()();

  TextColumn get bootstrapVersion => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
