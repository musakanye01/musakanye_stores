import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient _client;
  ProductService(this._client);

  Future<Result<List<CatalogueItem>>> fetchCatalogue() async {
    try {
      final rows = await _client
          .from('product_variants')
          .select(
            'id, sku, size, colour, price_cents, stock_on_hand, '
            'products!inner(id, name, active, categories(name))',
          )
          .eq('active', true)
          .eq('products.active', true);

      final items = rows.map((r) => CatalogueItem.fromJson(r)).toList()
        ..sort((a, b) {
          final byName = a.productName.toLowerCase().compareTo(
            b.productName.toLowerCase(),
          );
          return byName != 0
              ? byName
              : (a.variantLabel ?? '').compareTo(b.variantLabel ?? '');
        });

      return Result.ok(items);
    } on PostgrestException catch (e) {
      return Result.error(Exception(e.message));
    } catch (_) {
      return Result.error(
        Exception('Could not load products. Check your connection.'),
      );
    }
  }
}
