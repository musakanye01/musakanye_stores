import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_tablet/data/sync/connectivity_service.dart';
import 'package:pos_tablet/data/sync/sale_sync_service.dart';
import 'package:pos_tablet/data/sync/shift_sync_service.dart';

enum SyncStatus { idle, syncing, waitingForNetwork, success, syncFailed }

abstract interface class SyncCoordinator {
  SyncStatus get status;

  DateTime? get lastSuccessfulSync;

  Future<void> initialize();

  Future<void> triggerSync();
}

class SyncCoordinatorImp extends ChangeNotifier implements SyncCoordinator {
  final ShiftSyncService _shiftSyncService;
  final ConnectivityService _connectivityService;
  final SaleSyncService _salesSyncService;

  SyncCoordinatorImp({
    required this._shiftSyncService,
    required this._connectivityService,
    required this._salesSyncService,
  });

  bool _syncing = false;

  SyncStatus _status = SyncStatus.idle;

  DateTime? _lastSuccessfulSync;

  // ignore: unused_field
  StreamSubscription<bool>? _subscription;

  Timer? _heartbeat;

  @override
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  @override
  SyncStatus get status => _status;

  @override
  Future<void> triggerSync() async {
    if (_syncing) {
      return;
    }

    _syncing = true;

    try {
      _status = SyncStatus.syncing;
      notifyListeners();

      await _runPipeline();

      _lastSuccessfulSync = DateTime.now();

      _status = SyncStatus.idle;
    } catch (_) {
      _status = SyncStatus.syncFailed; //todo: check
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  @override
  Future<void> initialize() async {
    _heartbeat = Timer.periodic(
      const Duration(minutes: 5),
      (_) => triggerSync(),
    );
    _subscription = _connectivityService.onlineChanges.listen(
      _handleConnectivityChanged,
    );

    if (await _connectivityService.isOnline) {
      unawaited(triggerSync());
    } else {
      _status = SyncStatus.waitingForNetwork;
      notifyListeners();
    }
  }

  Future<void> _handleConnectivityChanged(bool online) async {
    if (!online) {
      _status = SyncStatus.waitingForNetwork;
      notifyListeners();
      return;
    }

    await triggerSync();
  }

  Future<void> _runPipeline() async {
    await _shiftSyncService.syncOpenShifts();

    await _salesSyncService.syncSales();

    await _shiftSyncService.syncClosedShifts();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _heartbeat?.cancel();
    super.dispose();
  }
}
