import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryService {
  InventoryService(this._client);

  final SupabaseClient _client;

  /// Loads active sellable variants with their product and category.
  Future<List<CatalogueItem>> fetchInventory() async {
    try {
      final response = await _client
          .from('product_variants')
          .select(
            'id, product_id, sku, size, colour, price_cents, '
            'stock_on_hand, active, '
            'products!inner('
            'id, name, description, category_id, active, '
            'categories(id, name, active)'
            ')',
          )
          .eq('active', true)
          .eq('products.active', true)
          .order('name', referencedTable: 'products');

      return (response as List)
          .map(
            (row) =>
                CatalogueItem.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList(growable: false);
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception('Failed to load inventory: $error');
    }
  }

  /// Loads active categories for the product form.
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('id, name')
          .eq('active', true)
          .order('name');

      return (response as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList(growable: false);
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception('Failed to load categories: $error');
    }
  }

  /// Creates a product and its initial variant atomically.
  Future<Map<String, dynamic>> createProduct({
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
      final response = await _client.rpc(
        'create_inventory_product',
        params: {
          'p_name': name.trim(),
          'p_category_id': categoryId,
          'p_description': description?.trim(),
          'p_sku': _nullableTrim(sku),
          'p_size': _nullableTrim(size),
          'p_colour': _nullableTrim(colour),
          'p_price_cents': priceCents,
          'p_initial_stock': initialStock,
        },
      );

      if (response is! Map) {
        throw Exception('Unexpected response from create_inventory_product');
      }

      return Map<String, dynamic>.from(response);
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception('Failed to create product: $error');
    }
  }

  Future<Map<String, dynamic>> updateProduct({
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
      final response = await _client.rpc(
        'update_inventory_product',
        params: {
          'p_product_id': productId,
          'p_variant_id': variantId,
          'p_name': name.trim(),
          'p_category_id': categoryId,
          'p_description': _nullableTrim(description),
          'p_sku': _nullableTrim(sku),
          'p_size': _nullableTrim(size),
          'p_colour': _nullableTrim(colour),
          'p_price_cents': priceCents,
        },
      );

      if (response is! Map) {
        throw Exception('Unexpected response from update_inventory_product');
      }

      return Map<String, dynamic>.from(response);
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception('Failed to update product: $error');
    }
  }

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
