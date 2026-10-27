import 'package:drift/drift.dart';

/// Local catalogue cache. Refreshed from Supabase whenever the device is online.
class CatalogueTable extends Table {
  @override
  String get tableName => 'catalogue';

  TextColumn get variantId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get size => text().nullable()();
  TextColumn get colour => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get priceCents => integer()();
  IntColumn get stockOnHand => integer()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {variantId};
}
