import 'package:pos_tablet/data/source/sale_service.dart';
import 'package:pos_tablet/data/sync/model/pending_sale_sync.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/util/result.dart';

class SuccessSaleService implements SaleService {
  @override
  Future<Result<SaleResult>> syncOfflineSale({
    required PendingSaleSync saleSync,
  }) async {
    return Result.ok(
      SaleResult(
        saleId: saleSync.sale.id,
        totalCents: saleSync.sale.totalCents,
        duplicate: false,
      ),
    );
  }
}
