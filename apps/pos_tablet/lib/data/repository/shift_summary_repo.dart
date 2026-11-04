import 'package:pos_tablet/data/local/dao/sales_dao.dart';
import 'package:shared_core/domain/model/shift_sales_summary.dart';

abstract class ShiftSummaryRepository {
  Stream<ShiftSalesSummary> watchSummary(String shiftId);
}

class ShiftSummaryRepositoryImpl implements ShiftSummaryRepository {
  ShiftSummaryRepositoryImpl(this._salesDao);
  final SalesDao _salesDao;

  @override
  Stream<ShiftSalesSummary> watchSummary(String shiftId) =>
      _salesDao.watchShiftSummary(shiftId);
}
