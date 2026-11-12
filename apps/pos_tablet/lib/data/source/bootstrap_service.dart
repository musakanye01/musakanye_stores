import 'package:flutter/material.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_core/domain/model/boot_strap_model.dart';

class BootstrapService {
  BootstrapService(this._client);

  final SupabaseClient _client;

  Future<Result<List<BootstrapCatalogueItem>>> fetchCatalogue() async {
    try {
      final result = await _client.rpc('get_catalogue');

      final catalogue = (result as List)
          .map(
            (item) =>
                BootstrapCatalogueItem.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return Result.ok(catalogue);
    } on PostgrestException catch (exception) {
      debugPrint(exception.message);
      return Result.error(exception);
    } on Exception catch (exception, stackTrace) {
      debugPrint("Error fetching catalogue: $exception");
      debugPrintStack(stackTrace: stackTrace);
      return Result.error(exception);
    }
  }
}

//TODO: Remote Monitoring of bugs etc
