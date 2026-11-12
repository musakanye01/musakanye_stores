import 'package:pos_tablet/data/local/dao/bootstrap_dao.dart';
import 'package:pos_tablet/data/source/bootstrap_service.dart';
import 'package:shared_core/domain/model/boot_strap_model.dart';
import 'package:shared_core/util/result.dart';

abstract interface class BootstrapRepository {
  Future<Result<void>> runBootstrap();
  Future<Result<bool>> isBootstrapped();
}

class BootstrapRepositoryImpl implements BootstrapRepository {
  BootstrapRepositoryImpl(this._service, this._dao);

  final BootstrapService _service;
  final BootstrapDao _dao;

  @override
  Future<Result<void>> runBootstrap() async {
    final result = await _service.fetchCatalogue();

    switch (result) {
      case Error<List<BootstrapCatalogueItem>>():
        return Result.error(result.error);

      case Ok<List<BootstrapCatalogueItem>>():
        final catalogue = result.value;

        if (catalogue.isEmpty) {
          return Result.error(
            Exception('Catalogue bootstrap returned no products.'),
          );
        }

        return _dao.bootstrapCatalogue(catalogue);
    }
  }

  @override
  Future<Result<bool>> isBootstrapped() => _dao.isBootstrapped();
}
