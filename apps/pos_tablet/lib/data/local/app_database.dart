import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:pos_tablet/data/local/dao/bootstrap_dao.dart';
import 'package:pos_tablet/data/local/dao/catalogue_dao.dart';
import 'package:pos_tablet/data/local/dao/sales_dao.dart';
import 'package:pos_tablet/data/local/dao/shifts_dao.dart';
import 'package:pos_tablet/data/local/dao/stock_receipts_dao.dart';
import 'package:pos_tablet/data/local/tables/bootstrap_table.dart';
import 'package:pos_tablet/data/local/tables/catalogue_table.dart';
import 'package:pos_tablet/data/local/tables/sale_lines_table.dart';
import 'package:pos_tablet/data/local/tables/sales_table.dart';
import 'package:pos_tablet/data/local/tables/shifts_table.dart';
import 'package:pos_tablet/data/local/tables/stock_receipts_table.dart';
import 'package:meta/meta.dart' show visibleForTesting;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ShiftsTable,
    SalesTable,
    SaleLinesTable,
    CatalogueTable,
    StockReceiptsTable,
    BootstrapState,
  ],
  daos: [ShiftsDao, SalesDao, CatalogueDao, StockReceiptsDao, BootstrapDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'pos_database');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {},
    );
  }
}
