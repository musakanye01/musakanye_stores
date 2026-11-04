// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_dao.dart';

// ignore_for_file: type=lint
mixin _$CatalogueDaoMixin on DatabaseAccessor<AppDatabase> {
  $CatalogueTableTable get catalogueTable => attachedDatabase.catalogueTable;
  CatalogueDaoManager get managers => CatalogueDaoManager(this);
}

class CatalogueDaoManager {
  final _$CatalogueDaoMixin _db;
  CatalogueDaoManager(this._db);
  $$CatalogueTableTableTableManager get catalogueTable =>
      $$CatalogueTableTableTableManager(
        _db.attachedDatabase,
        _db.catalogueTable,
      );
}
