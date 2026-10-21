import 'package:flutter/foundation.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:shared_core/domain/sale_history.dart';

class SalesHistoryViewModel extends ChangeNotifier {
  SalesHistoryViewModel(this._repository);

  final SaleRepository _repository;

  static const int _pageSize = 50;

  final List<SaleHistory> _sales = [];
  List<SaleHistory> get sales => List.unmodifiable(_sales);

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;
  String searchQuery = '';

  int _offset = 0;

  List<SaleHistory> get filteredSales {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return sales;

    return _sales.where((sale) {
      return sale.id.toLowerCase().contains(query) ||
          sale.paymentMethod.toLowerCase().contains(query) ||
          sale.status.toLowerCase().contains(query) ||
          sale.totalCents.toString().contains(query);
    }).toList();
  }

  Future<void> loadInitial() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    _offset = 0;
    hasMore = true;
    _sales.clear();
    notifyListeners();

    try {
      final page = await _repository.getSalesHistory(
        offset: 0,
        limit: _pageSize,
      );

      _sales.addAll(page);
      _offset = page.length;
      hasMore = page.length == _pageSize;
    } catch (e) {
      errorMessage = _messageFor(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _repository.getSalesHistory(
        offset: _offset,
        limit: _pageSize,
      );

      _sales.addAll(page);
      _offset += page.length;
      hasMore = page.length == _pageSize;
    } catch (e) {
      errorMessage = _messageFor(e);
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> loadReceipt(String saleId) {
    return _repository.getSaleReceipt(saleId);
  }

  String _messageFor(Object error) {
    return 'Could not load sales history. Check your connection and try again.';
  }
}
