import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityService {
  Stream<bool> get onlineChanges;

  Future<bool> get isOnline;
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Stream<bool> get onlineChanges => _connectivity.onConnectivityChanged.map(
    (results) =>
        results.isNotEmpty && !results.contains(ConnectivityResult.none),
  );

  @override
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();

    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}
