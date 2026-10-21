
import 'package:flutter/material.dart';
import 'package:pos_tablet/data/repository/stock_repo.dart';
import 'package:shared_core/domain/catalogue_item.dart';
import 'package:shared_core/domain/stock_receiving_item.dart';
import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';
import 'package:uuid/uuid.dart';



class StockReceivingViewModel extends ChangeNotifier {
  final StockReceivingRepository _repository;
  final Uuid _uuid = const Uuid();

  StockReceivingViewModel(this._repository) {
    loadProducts = Command0(_handleLoadProducts);
    loadRecentItems = Command0(_handleLoadRecentItems);
    submitReceipt = Command0(_handleSubmitReceipt);
  }

  late final Command0<void> loadProducts;
  late final Command0<void> loadRecentItems;
  late final Command0<void> submitReceipt;

  List<CatalogueItem> _products = [];
  List<StockReceiptItem> _recentItems = [];

  String? _selectedVariantId;
  String _quantityText = '';
  String _note = '';
  String _reference = '';

  bool _submitting = false;

  // Keep retry IDs and payload stable after an ambiguous failure.
  String? _pendingReceiptId;
  String? _pendingIdempotencyKey;
  String? _pendingPayloadKey;

  List<CatalogueItem> get products => List.unmodifiable(_products);
  List<StockReceiptItem> get recentItems =>
      List.unmodifiable(_recentItems);

  String? get selectedVariantId => _selectedVariantId;
  String get quantityText => _quantityText;
  String get note => _note;
  String get reference => _reference;
  bool get submitting => _submitting;

  CatalogueItem? get selectedProduct {
    for (final item in _products) {
      if (item.variantId == _selectedVariantId) return item;
    }
    return null;
  }

  void selectVariant(String? variantId) {
    _selectedVariantId = variantId;
    _resetPendingRequest();
    notifyListeners();
  }

  void setQuantity(String value) {
    _quantityText = value;
    _resetPendingRequest();
    notifyListeners();
  }

  void setNote(String value) {
    _note = value;
    _resetPendingRequest();
    notifyListeners();
  }

  void setReference(String value) {
    _reference = value;
    _resetPendingRequest();
    notifyListeners();
  }

  void _resetPendingRequest() {
    _pendingReceiptId = null;
    _pendingIdempotencyKey = null;
    _pendingPayloadKey = null;
  }

  Future<Result<void>> _handleLoadProducts() async {
    final result = await _repository.getProducts();

    switch (result) {
      case Ok<List<CatalogueItem>>(value: final items):
        _products = items;
        notifyListeners();
        return const Result.ok(null);

      case Error<List<CatalogueItem>>(error: final err):
        return Result.error(err);
    }
  }

  Future<Result<void>> _handleLoadRecentItems() async {
    final result = await _repository.getRecentItems();

    switch (result) {
      case Ok<List<StockReceiptItem>>(value: final items):
        _recentItems = items;
        notifyListeners();
        return const Result.ok(null);

      case Error<List<StockReceiptItem>>(error: final err):
        return Result.error(err);
    }
  }

  Future<Result<void>> _handleSubmitReceipt() async {
    if (_submitting) {
      return Result.error(Exception('A receipt is already being submitted.'));
    }

    final variantId = _selectedVariantId;
    final quantity = int.tryParse(_quantityText.trim());

    if (variantId == null || selectedProduct == null) {
      return Result.error(Exception('Please select a product variant.'));
    }

    if (quantity == null || quantity <= 0) {
      return Result.error(
        Exception('Enter a valid quantity greater than zero.'),
      );
    }

    final note = _note.trim();
    final reference = _reference.trim();
    final payloadKey = '$variantId|$quantity|$note|$reference';

    if (_pendingPayloadKey != payloadKey) {
      _pendingReceiptId = _uuid.v4();
      _pendingIdempotencyKey = _uuid.v4();
      _pendingPayloadKey = payloadKey;
    }

    _submitting = true;
    notifyListeners();

    try {
      final result = await _repository.submitReceipt(
        receiptId: _pendingReceiptId!,
        idempotencyKey: _pendingIdempotencyKey!,
        variantId: variantId,
        quantity: quantity,
        note: note,
        reference: reference.isEmpty ? null : reference,
      );

      switch (result) {
        case Ok<void>():
          _resetPendingRequest();
          _selectedVariantId = null;
          _quantityText = '';
          _note = '';
          _reference = '';

          // Refresh both data sources after a successful submission.
          final productsResult = await _repository.getProducts();
          if (productsResult case Ok<List<CatalogueItem>>(
            value: final items,
          )) {
            _products = items;
          }

          final historyResult = await _repository.getRecentItems();
          if (historyResult case Ok<List<StockReceiptItem>>(
            value: final items,
          )) {
            _recentItems = items;
          }

          notifyListeners();
          return const Result.ok(null);

        case Error<void>(error: final err):
          // Retain request IDs so a retry can be idempotent.
          return Result.error(err);
      }
    } catch (error) {
      return Result.error(Exception('Could not submit the stock receipt.'));
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
