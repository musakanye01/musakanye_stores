import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/tables/bootstrap_table.dart';
import 'package:pos_tablet/data/local/tables/catalogue_table.dart';
import 'package:shared_core/domain/model/boot_strap_model.dart';
import 'package:shared_core/util/result.dart';

part 'bootstrap_dao.g.dart';

@DriftAccessor(tables: [CatalogueTable, BootstrapState])
class BootstrapDao extends DatabaseAccessor<AppDatabase>
    with _$BootstrapDaoMixin {
  BootstrapDao(super.db);

  Future<Result<void>> bootstrapCatalogue(
    List<BootstrapCatalogueItem> items,
  ) async {
    try {
      final cachedAt = DateTime.now();

      await transaction(() async {
        await delete(catalogueTable).go();

        await batch((batch) {
          batch.insertAll(
            catalogueTable,
            items
                .map(
                  (item) => CatalogueTableCompanion.insert(
                    variantId: item.variantId,
                    productId: item.productId,
                    productName: item.productName,
                    categoryId: Value(item.categoryId),
                    categoryName: Value(item.categoryName),
                    sku: Value(item.sku),
                    size: Value(item.size),
                    colour: Value(item.colour),
                    description: Value(item.description),
                    priceCents: item.priceCents,
                    stockOnHand: item.stockOnHand,
                    cachedAt: cachedAt,
                  ),
                )
                .toList(),
          );
        });

        await into(bootstrapState).insertOnConflictUpdate(
          BootstrapStateCompanion(
            id: const Value(1),
            completedAt: Value(DateTime.now()),
          ),
        );
      });

      return const Result.ok(null);
    } on Exception catch (exception, stackTrace) {
      debugPrint('Failed to bootstrap catalogue: $exception');
      debugPrintStack(stackTrace: stackTrace);

      return Result.error(exception);
    }
  }

  Future<Result<bool>> isBootstrapped() async {
    try {
      final state = await select(bootstrapState).getSingleOrNull();

      return Result.ok(state != null && state.completedAt != null);
    } on Exception catch (exception, stackTrace) {
      debugPrint('Failed to check bootstrap state: $exception');
      debugPrintStack(stackTrace: stackTrace);

      return Result.error(exception);
    }
  }
}
