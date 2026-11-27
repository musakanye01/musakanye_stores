import 'package:flutter/foundation.dart';
import 'package:owner/data/repo/owner_operations_repo.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';

class OwnerOperationsViewModel extends ChangeNotifier {
  OwnerOperationsViewModel(this._repository) {
    loadSales = Command0(_loadSales);
    loadSales.execute();
  }

  final OwnerOperationsRepository _repository;

  late final Command0<void> loadSales;

  List<SaleHistory> _sales = [];

  List<SaleHistory> get sales => List.unmodifiable(_sales);

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

  @override
  void dispose() {
    loadSales.dispose();
    super.dispose();
  }
}
