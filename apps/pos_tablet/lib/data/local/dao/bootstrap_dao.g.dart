// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_dao.dart';

// ignore_for_file: type=lint
mixin _$BootstrapDaoMixin on DatabaseAccessor<AppDatabase> {
  $CatalogueTableTable get catalogueTable => attachedDatabase.catalogueTable;
  $BootstrapStateTable get bootstrapState => attachedDatabase.bootstrapState;
  BootstrapDaoManager get managers => BootstrapDaoManager(this);
}

class BootstrapDaoManager {
  final _$BootstrapDaoMixin _db;
  BootstrapDaoManager(this._db);
  $$CatalogueTableTableTableManager get catalogueTable =>
      $$CatalogueTableTableTableManager(
        _db.attachedDatabase,
        _db.catalogueTable,
      );
  $$BootstrapStateTableTableManager get bootstrapState =>
      $$BootstrapStateTableTableManager(
        _db.attachedDatabase,
        _db.bootstrapState,
      );
}
