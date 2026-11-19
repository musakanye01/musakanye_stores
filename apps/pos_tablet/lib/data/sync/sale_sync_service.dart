import 'package:pos_tablet/data/local/dao/sales_dao.dart';
import 'package:pos_tablet/data/source/sale_service.dart';
import 'package:pos_tablet/data/sync/model/pending_sale_sync.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/util/result.dart';

abstract interface class SaleSyncService {
  Future<void> syncSales();
}

class SaleSyncServiceImpl implements SaleSyncService {
  SaleSyncServiceImpl(this._salesDao, this._saleService);

  final SalesDao _salesDao;
  final SaleService _saleService;

  @override
  Future<void> syncSales() async {
    final pendingSales = await _salesDao.getPendingSalesForSync();

    for (final pending in pendingSales) {
      await _syncSale(pending);
    }
  }

  Future<void> _syncSale(PendingSaleSync pending) async {
    try {
      print('Syncing sale: ${pending.sale.id}');
      final result = await _saleService.syncOfflineSale(saleSync: pending);

      print('Result type: ${result.runtimeType}');
      switch (result) {
        case Ok<SaleResult>():
          print('SUCCESS: ${pending.sale.id}');
          await _salesDao.markSynced(pending.sale.id);

        case Error<SaleResult>():
          print('FAILURE: ${pending.sale.id}');
          print('ERROR: ${result.error}');

          await _salesDao.markSyncFailed(
            pending.sale.id,
            result.error.toString(),
          );
      }
    } catch (exception) {
      await _salesDao.markSyncFailed(pending.sale.id, exception.toString());
    }
  }
}
