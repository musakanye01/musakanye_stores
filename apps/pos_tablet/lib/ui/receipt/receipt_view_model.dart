import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:shared_core/domain/model/sale_receipt.dart';

class ReceiptViewModel extends ChangeNotifier {
  ReceiptViewModel(this._repository, this.saleId) {
    unawaited(
      _load(),
    ); // starts in the loading state, so no notify is needed first
  }

  final SaleRepository _repository;
  final String saleId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SaleReceipt? _receipt;
  SaleReceipt? get receipt => _receipt;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _disposed = false;

  Future<void> retry() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    return _load();
  }

  Future<void> _load() async {
    try {
      _receipt = await _repository.getSaleReceipt(saleId);
      _errorMessage = null;
    } catch (_) {
      _errorMessage =
          'Could not read this receipt from this device. Please try again.';
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
