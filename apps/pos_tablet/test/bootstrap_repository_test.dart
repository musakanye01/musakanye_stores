import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/dao/bootstrap_dao.dart';
import 'package:pos_tablet/data/repository/bootsrap_repository.dart';
import 'package:pos_tablet/data/source/bootstrap_service.dart';
import 'package:shared_core/domain/model/boot_strap_model.dart';
import 'package:shared_core/util/result.dart';

void main() {
  group('runBootstrap', () {
    test('returns service error when catalogue fetch fails', () async {
      final repository = BootstrapRepositoryImpl(
        _ErrorBootstrapService(),
        _SuccessBootstrapDao(),
      );

      final result = await repository.runBootstrap();

      switch (result) {
        case Ok<void>():
          fail('Expected Error');

        case Error<void>():
          expect(result.error.toString(), contains('RPC failed'));
      }
    });

    test('returns error when catalogue is empty', () async {
      final repository = BootstrapRepositoryImpl(
        _EmptyBootstrapService(),
        _SuccessBootstrapDao(),
      );

      final result = await repository.runBootstrap();

      switch (result) {
        case Ok<void>():
          fail('Expected Error');

        case Error<void>():
          expect(
            result.error.toString(),
            contains('Catalogue bootstrap returned no products'),
          );
      }
    });

    test('calls dao when catalogue exists', () async {
      final dao = _SuccessBootstrapDao();

      final repository = BootstrapRepositoryImpl(
        _SuccessBootstrapService(),
        dao,
      );

      final result = await repository.runBootstrap();

      expect(dao.bootstrapCalled, true);

      expect(dao.receivedItems.length, 1);

      switch (result) {
        case Ok<void>():
          break;

        case Error<void>():
          fail(result.error.toString());
      }
    });

    test('returns dao failure when catalogue write fails', () async {
      final repository = BootstrapRepositoryImpl(
        _SuccessBootstrapService(),
        _FailingBootstrapDao(),
      );

      final result = await repository.runBootstrap();

      switch (result) {
        case Ok<void>():
          fail('Expected Error');

        case Error<void>():
          expect(result.error.toString(), contains('Database failure'));
      }
    });
  });

  group('isBootstrapped', () {
    test('returns true when dao returns true', () async {
      final repository = BootstrapRepositoryImpl(
        _SuccessBootstrapService(),
        _BootstrappedDao(),
      );

      final result = await repository.isBootstrapped();

      switch (result) {
        case Ok<bool>():
          expect(result.value, true);

        case Error<bool>():
          fail(result.error.toString());
      }
    });

    test('returns false when dao returns false', () async {
      final repository = BootstrapRepositoryImpl(
        _SuccessBootstrapService(),
        _NotBootstrappedDao(),
      );

      final result = await repository.isBootstrapped();

      switch (result) {
        case Ok<bool>():
          expect(result.value, false);

        case Error<bool>():
          fail(result.error.toString());
      }
    });
  });
}

final _catalogue = [
  BootstrapCatalogueItem(
    variantId: 'v1',
    productId: 'p1',
    productName: 'Coke',
    categoryId: 'c1',
    categoryName: 'Drinks',
    sku: 'SKU1',
    size: '300ml',
    colour: null,
    description: null,
    priceCents: 150,
    stockOnHand: 10,
  ),
];

class _SuccessBootstrapService extends Fake implements BootstrapService {
  @override
  Future<Result<List<BootstrapCatalogueItem>>> fetchCatalogue() async {
    return Result.ok(_catalogue);
  }
}

class _EmptyBootstrapService extends Fake implements BootstrapService {
  @override
  Future<Result<List<BootstrapCatalogueItem>>> fetchCatalogue() async {
    return const Result.ok([]);
  }
}

class _ErrorBootstrapService extends Fake implements BootstrapService {
  @override
  Future<Result<List<BootstrapCatalogueItem>>> fetchCatalogue() async {
    return Result.error(Exception('RPC failed'));
  }
}

class _SuccessBootstrapDao extends Fake implements BootstrapDao {
  bool bootstrapCalled = false;

  List<BootstrapCatalogueItem> receivedItems = [];

  @override
  Future<Result<void>> bootstrapCatalogue(
    List<BootstrapCatalogueItem> items,
  ) async {
    bootstrapCalled = true;
    receivedItems = items;

    return const Result.ok(null);
  }

  @override
  Future<Result<bool>> isBootstrapped() async {
    return const Result.ok(true);
  }
}

class _FailingBootstrapDao extends Fake implements BootstrapDao {
  @override
  Future<Result<void>> bootstrapCatalogue(
    List<BootstrapCatalogueItem> items,
  ) async {
    return Result.error(Exception('Database failure'));
  }

  @override
  Future<Result<bool>> isBootstrapped() async {
    return const Result.ok(false);
  }
}

class _BootstrappedDao extends Fake implements BootstrapDao {
  @override
  Future<Result<void>> bootstrapCatalogue(
    List<BootstrapCatalogueItem> items,
  ) async {
    return const Result.ok(null);
  }

  @override
  Future<Result<bool>> isBootstrapped() async {
    return const Result.ok(true);
  }
}

class _NotBootstrappedDao extends Fake implements BootstrapDao {
  @override
  Future<Result<void>> bootstrapCatalogue(
    List<BootstrapCatalogueItem> items,
  ) async {
    return const Result.ok(null);
  }

  @override
  Future<Result<bool>> isBootstrapped() async {
    return const Result.ok(false);
  }
}
