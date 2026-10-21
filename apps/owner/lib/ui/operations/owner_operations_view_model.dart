import 'package:flutter/foundation.dart';
import 'package:owner/data/repo/owner_operations_repo.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';

class OwnerOperationsViewModel extends ChangeNotifier {
  OwnerOperationsViewModel(this._repository) {
    loadSales = Command0(_loadSales);
    loadShifts = Command0(_loadShifts);

    loadSales.execute();
    loadShifts.execute();
  }

  final OwnerOperationsRepository _repository;

  late final Command0<void> loadSales;
  late final Command0<void> loadShifts;

  List<SaleHistory> _sales = [];
  List<Shift> _shifts = [];

  List<SaleHistory> get sales => List.unmodifiable(_sales);
  List<Shift> get shifts => List.unmodifiable(_shifts);

  Shift? get openShift {
    for (final shift in _shifts) {
      if (shift.status.toLowerCase() == 'open') {
        return shift;
      }
    }

    return null;
  }

  Future<Result<void>> _loadSales() async {
    final result = await _repository.getSales();

    switch (result) {
      case Ok<List<SaleHistory>>(value: final sales):
        _sales = sales;
        notifyListeners();
        return const Result.ok(null);

      case Error<List<SaleHistory>>(error: final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _loadShifts() async {
    final result = await _repository.getShifts();

    switch (result) {
      case Ok<List<Shift>>(value: final shifts):
        _shifts = shifts;
        notifyListeners();
        return const Result.ok(null);

      case Error<List<Shift>>(error: final error):
        return Result.error(error);
    }
  }

  @override
  void dispose() {
    loadSales.dispose();
    loadShifts.dispose();
    super.dispose();
  }
}
