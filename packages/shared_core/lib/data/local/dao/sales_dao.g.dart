// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_dao.dart';

// ignore_for_file: type=lint
mixin _$SalesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SalesTableTable get salesTable => attachedDatabase.salesTable;
  $SaleLinesTableTable get saleLinesTable => attachedDatabase.saleLinesTable;
  SalesDaoManager get managers => SalesDaoManager(this);
}

class SalesDaoManager {
  final _$SalesDaoMixin _db;
  SalesDaoManager(this._db);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db.attachedDatabase, _db.salesTable);
  $$SaleLinesTableTableTableManager get saleLinesTable =>
      $$SaleLinesTableTableTableManager(
        _db.attachedDatabase,
        _db.saleLinesTable,
      );
}
