import 'package:drift/drift.dart';

/// Line items belonging to a sale (stored locally alongside the sale header).
class SaleLinesTable extends Table {
  @override
  String get tableName => 'sale_lines';

  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get variantId => text()();
  IntColumn get quantity => integer()();
  IntColumn get unitPriceCents => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
