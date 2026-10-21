import 'package:flutter/foundation.dart';
import 'package:owner/data/repo/inventory_repo.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/util/result.dart';

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._repository);

  final InventoryRepository _repository;

  List<CatalogueItem> _inventory = [];
  List<Map<String, dynamic>> _categories = [];

  bool _isLoading = false;
  bool _isLoadingCategories = false;
  bool _isCreatingProduct = false;
  bool _lowStockOnly = false;
  String _searchQuery = '';
  String? _errorMessage;
  String? _categoryErrorMessage;
  bool _isUpdatingProduct = false;

  List<CatalogueItem> get inventory => List.unmodifiable(_inventory);

  List<Map<String, dynamic>> get categories => List.unmodifiable(_categories);

  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isCreatingProduct => _isCreatingProduct;
  bool get lowStockOnly => _lowStockOnly;
  bool get isUpdatingProduct => _isUpdatingProduct;

  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  String? get categoryErrorMessage => _categoryErrorMessage;

  /// Replace this with your existing shared application threshold.
  /// It is an application-wide rule, not a per-product database field.
  static const int lowStockThreshold = 5;

  List<CatalogueItem> get filteredInventory {
    final query = _searchQuery.trim().toLowerCase();

    final items = _inventory.where((item) {
      final matchesSearch =
          query.isEmpty ||
          item.productName.toLowerCase().contains(query) ||
          (item.categoryName ?? '').toLowerCase().contains(query) ||
          (item.sku ?? '').toLowerCase().contains(query) ||
          (item.size ?? '').toLowerCase().contains(query) ||
          (item.colour ?? '').toLowerCase().contains(query);

      final matchesStock =
          !_lowStockOnly || item.stockOnHand <= lowStockThreshold;

      return matchesSearch && matchesStock;
    }).toList();

    items.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );

    return items;
  }

  int get productCount => _inventory.length;

  int get totalUnits =>
      _inventory.fold<int>(0, (total, item) => total + item.stockOnHand);

  int get lowStockCount =>
      _inventory.where((item) => item.stockOnHand <= lowStockThreshold).length;

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;

    _searchQuery = value;
    notifyListeners();
  }

  void toggleLowStockFilter() {
    _lowStockOnly = !_lowStockOnly;
    notifyListeners();
  }

  void setLowStockFilter(bool enabled) {
    if (_lowStockOnly == enabled) return;

    _lowStockOnly = enabled;
    notifyListeners();
  }

  Future<void> loadInventory() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getInventory();

      switch (result) {
        case Ok<List<CatalogueItem>>(:final value):
          _inventory = value;
        case Error<List<CatalogueItem>>(:final error):
          _errorMessage = error.toString();
      }
    } catch (error) {
      _errorMessage = 'Unable to load inventory: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    if (_isLoadingCategories) return;

    _isLoadingCategories = true;
    _categoryErrorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getCategories();

      switch (result) {
        case Ok<List<Map<String, dynamic>>>(:final value):
          _categories = value;
        case Error<List<Map<String, dynamic>>>(:final error):
          _categoryErrorMessage = error.toString();
      }
    } catch (error) {
      _categoryErrorMessage = 'Unable to load categories: $error';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String variantId,
    required String name,
    String? categoryId,
    String? description,
    String? sku,
    String? size,
    String? colour,
    required int priceCents,
  }) async {
    if (_isUpdatingProduct) return false;

    _isUpdatingProduct = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.updateProduct(
        productId: productId,
        variantId: variantId,
        name: name,
        categoryId: categoryId,
        description: description,
        sku: sku,
        size: size,
        colour: colour,
        priceCents: priceCents,
      );

      switch (result) {
        case Error<Map<String, dynamic>>(:final error):
          _errorMessage = error.toString();
          return false;

        case Ok<Map<String, dynamic>>():
          final inventoryResult = await _repository.getInventory();

          switch (inventoryResult) {
            case Ok<List<CatalogueItem>>(:final value):
              _inventory = value;
              return true;

            case Error<List<CatalogueItem>>(:final error):
              _errorMessage =
                  'Product was updated, but inventory could not refresh: '
                  '$error';
              // The server update succeeded; don't invite a duplicate edit.
              return true;
          }
      }
    } catch (error) {
      _errorMessage = 'Unable to update product: $error';
      return false;
    } finally {
      _isUpdatingProduct = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String name,
    String? categoryId,
    String? description,
    String? sku,
    String? size,
    String? colour,
    required int priceCents,
    required int initialStock,
  }) async {
    if (_isCreatingProduct) return false;

    _isCreatingProduct = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createProduct(
        name: name,
        categoryId: categoryId,
        description: description,
        sku: sku,
        size: size,
        colour: colour,
        priceCents: priceCents,
        initialStock: initialStock,
      );

      switch (result) {
        case Error<Map<String, dynamic>>(:final error):
          _errorMessage = error.toString();
          return false;

        case Ok<Map<String, dynamic>>():
          // Refresh the list after the server confirms creation.
          final inventoryResult = await _repository.getInventory();

          switch (inventoryResult) {
            case Ok<List<CatalogueItem>>(:final value):
              _inventory = value;
              return true;

            case Error<List<CatalogueItem>>(:final error):
              // Creation succeeded, but refreshing failed.
              _errorMessage =
                  'Product was created, but inventory could not refresh: '
                  '$error';
              return true;
          }
      }
    } catch (error) {
      _errorMessage = 'Unable to create product: $error';
      return false;
    } finally {
      _isCreatingProduct = false;
      notifyListeners();
    }
  }

  /// Clears transient error messages after the UI has displayed them.
  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }

  void clearCategoryError() {
    if (_categoryErrorMessage == null) return;

    _categoryErrorMessage = null;
    notifyListeners();
  }
}
