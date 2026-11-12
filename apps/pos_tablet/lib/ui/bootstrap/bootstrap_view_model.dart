import 'package:flutter/foundation.dart';
import 'package:pos_tablet/data/repository/bootsrap_repository.dart';
import 'package:shared_core/util/result.dart';

enum BootstrapStatus {
  unknown,
  checking,
  required,
  bootstrapping,
  ready,
  error,
}

class BootstrapViewModel extends ChangeNotifier {
  BootstrapViewModel(this._repository);

  final BootstrapRepository _repository;

  BootstrapStatus _status = BootstrapStatus.unknown;

  BootstrapStatus get status => _status;

  bool get isReady => _status == BootstrapStatus.ready;

  bool get requiresBootstrap => _status == BootstrapStatus.required;

  bool get isBusy =>
      _status == BootstrapStatus.checking ||
      _status == BootstrapStatus.bootstrapping;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> restoreState() async {
    _status = BootstrapStatus.checking;
    notifyListeners();

    final result = await _repository.isBootstrapped();

    switch (result) {
      case Ok<bool>():
        _status = result.value
            ? BootstrapStatus.ready
            : BootstrapStatus.required;

      case Error<bool>():
        _status = BootstrapStatus.error;
        _errorMessage = result.error.toString();
    }

    notifyListeners();
  }

  Future<void> bootstrap() async {
    _status = BootstrapStatus.bootstrapping;
    _errorMessage = null;

    notifyListeners();

    final result = await _repository.runBootstrap();

    switch (result) {
      case Ok<void>():
        _status = BootstrapStatus.ready;

      case Error<void>():
        _status = BootstrapStatus.error;
        _errorMessage = result.error.toString();
    }

    notifyListeners();
  }
}
