import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_core/data/local/tables/catalogue_table.dart';
import 'package:shared_core/data/local/tables/sale_lines_table.dart';
import 'package:shared_core/data/local/tables/sales_table.dart';
import 'package:shared_core/data/local/tables/shifts_table.dart';
import 'package:shared_core/data/local/tables/stock_receipts_table.dart';
import 'package:shared_core/data/local/dao/shifts_dao.dart';
import 'package:shared_core/data/local/dao/sales_dao.dart';
import 'package:shared_core/data/local/dao/catalogue_dao.dart';
import 'package:shared_core/data/local/dao/stock_receipts_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ShiftsTable,
    SalesTable,
    SaleLinesTable,
    CatalogueTable,
    StockReceiptsTable,
  ],
  daos: [
    ShiftsDao,
    SalesDao,
    CatalogueDao,
    StockReceiptsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'pos_database');
  }
}
