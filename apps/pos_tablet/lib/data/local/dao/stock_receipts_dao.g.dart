// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_receipts_dao.dart';

// ignore_for_file: type=lint
mixin _$StockReceiptsDaoMixin on DatabaseAccessor<AppDatabase> {
  $StockReceiptsTableTable get stockReceiptsTable =>
      attachedDatabase.stockReceiptsTable;
  StockReceiptsDaoManager get managers => StockReceiptsDaoManager(this);
}

class StockReceiptsDaoManager {
  final _$StockReceiptsDaoMixin _db;
  StockReceiptsDaoManager(this._db);
  $$StockReceiptsTableTableTableManager get stockReceiptsTable =>
      $$StockReceiptsTableTableTableManager(
        _db.attachedDatabase,
        _db.stockReceiptsTable,
      );
}
