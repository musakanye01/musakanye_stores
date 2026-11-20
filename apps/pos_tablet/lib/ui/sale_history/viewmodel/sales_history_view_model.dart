import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:shared_core/domain/model/sale_history.dart';

class SalesHistoryViewModel extends ChangeNotifier {
  SalesHistoryViewModel(this._repository, this._shift) {
    _shift.addListener(_onShiftChanged);
    _onShiftChanged(); // the shift may already be open when we're created
  }

  final SaleRepository _repository;
  final ShiftViewModel _shift;

  @visibleForTesting
  int pageSize = 50;

  final List<SaleHistory> _sales = [];
  List<SaleHistory> get sales => List.unmodifiable(_sales);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _offset = 0;
  String? _boundShiftId;
  int _generation = 0; // bumped on every shift change; stale loads are dropped

  List<SaleHistory> get filteredSales {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return sales;

    return _sales.where((sale) {
      return sale.id.toLowerCase().contains(query) ||
          sale.paymentMethod.toLowerCase().contains(query) ||
          sale.status.toLowerCase().contains(query) ||
          sale.totalCents.toString().contains(query);
    }).toList();
  }

  void _onShiftChanged() {
    final id = _shift.currentShift?.id;
    if (id == _boundShiftId) return; // notified for another reason

    _boundShiftId = id;
    _generation++;
    _sales.clear();
    _offset = 0;
    _hasMore = false;
    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    notifyListeners();

    if (id != null) unawaited(loadInitial());
  }

  /// Reloads page one. The screen calls this on entry so sales rung up since
  /// it was last open appear. The existing list stays visible until the new
  /// page arrives.
  Future<void> loadInitial() async {
    final shiftId = _boundShiftId;
    if (shiftId == null || _isLoading) return;

    final generation = _generation;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _repository.getSalesHistory(
        shiftId: shiftId,
        offset: 0,
        limit: pageSize,
      );
      if (generation != _generation) return; // the shift changed meanwhile

      _sales
        ..clear()
        ..addAll(page);
      _offset = page.length;
      _hasMore = page.length == pageSize;
    } catch (e) {
      if (generation != _generation) return;
      _errorMessage = _messageFor(e);
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    final shiftId = _boundShiftId;
    if (shiftId == null || _isLoading || _isLoadingMore || !_hasMore) return;

    final generation = _generation;
    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _repository.getSalesHistory(
        shiftId: shiftId,
        offset: _offset,
        limit: pageSize,
      );
      if (generation != _generation) return;

      _sales.addAll(page);
      _offset += page.length;
      _hasMore = page.length == pageSize;
    } catch (e) {
      if (generation != _generation) return;
      _errorMessage = _messageFor(e);
    } finally {
      if (generation == _generation) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  String _messageFor(Object error) =>
      'Could not read sales history from this device. Please try again.';

  @override
  void dispose() {
    _shift.removeListener(_onShiftChanged);
    super.dispose();
  }
}
