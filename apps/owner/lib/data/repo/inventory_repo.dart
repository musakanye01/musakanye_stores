import 'package:owner/data/source/inventory_service.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/util/result.dart';

abstract interface class InventoryRepository {
  Future<Result<List<CatalogueItem>>> getInventory();

  Future<Result<List<Map<String, dynamic>>>> getCategories();

  Future<Result<Map<String, dynamic>>> createProduct({
    required String name,
    String? categoryId,
    String? description,
    String? sku,
    String? size,
    String? colour,
    required int priceCents,
    required int initialStock,
  });

  Future<Result<Map<String, dynamic>>> updateProduct({
    required String productId,
    required String variantId,
    required String name,
    String? categoryId,
    String? description,
    String? sku,
    String? size,
    String? colour,
    required int priceCents,
  });
}

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._service);

  final InventoryService _service;

  @override
  Future<Result<List<CatalogueItem>>> getInventory() async {
    try {
      return Result.ok(await _service.fetchInventory());
    } on Exception catch (error) {
      return Result.error(error);
    } catch (error) {
      return Result.error(Exception('Unable to load inventory: $error'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getCategories() async {
    try {
      return Result.ok(await _service.fetchCategories());
    } on Exception catch (error) {
      return Result.error(error);
    } catch (error) {
      return Result.error(Exception('Unable to load categories: $error'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> createProduct({
    required String name,
    String? categoryId,
    String? description,
    String? sku,
    String? size,
    String? colour,
    required int priceCents,
    required int initialStock,
  }) async {
    try {
      final result = await _service.createProduct(
        name: name,
        categoryId: categoryId,
        description: description,
        sku: sku,
        size: size,
        colour: colour,
        priceCents: priceCents,
        initialStock: initialStock,
      );

      return Result.ok(result);
    } on Exception catch (error) {
      return Result.error(error);
    } catch (error) {
      return Result.error(Exception('Unable to create product: $error'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> updateProduct({
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
    try {
      final result = await _service.updateProduct(
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

      return Result.ok(result);
    } on Exception catch (error) {
      return Result.error(error);
    } catch (error) {
      return Result.error(Exception('Unable to update product: $error'));
    }
  }
}
