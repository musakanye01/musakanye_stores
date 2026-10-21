import 'package:owner/data/source/owner_operations_service.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/util/result.dart';

abstract class OwnerOperationsRepository {
  Future<Result<List<SaleHistory>>> getSales();

  Future<Result<List<Shift>>> getShifts();
}

class OwnerOperationsRepositoryImpl implements OwnerOperationsRepository {
  OwnerOperationsRepositoryImpl({
    required OwnerOperationsService ownerOperationsService,
  }) : _service = ownerOperationsService;

  final OwnerOperationsService _service;

  @override
  Future<Result<List<SaleHistory>>> getSales() {
    return _service.fetchSales();
  }

  @override
  Future<Result<List<Shift>>> getShifts() {
    return _service.fetchShifts();
  }
}
