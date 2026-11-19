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
  bool _initialized = false;

  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSuccessfulSync;

  StreamSubscription<bool>? _subscription;
  Timer? _heartbeat;

  @override
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  @override
  SyncStatus get status => _status;

  void _updateStatus(SyncStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _subscription = _connectivityService.onlineChanges.listen(
      _handleConnectivityChanged,
    );

    _heartbeat = Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(triggerSync()),
    );

    if (await _connectivityService.isOnline) {
      unawaited(triggerSync());
    } else {
      _updateStatus(SyncStatus.waitingForNetwork);
    }
  }

  @override
  Future<void> triggerSync() async {
    if (_syncing) return;

    if (!await _connectivityService.isOnline) {
      _updateStatus(SyncStatus.waitingForNetwork);
      return;
    }

    _syncing = true;
    _updateStatus(SyncStatus.syncing);

    try {
      await _runPipeline();

      _lastSuccessfulSync = DateTime.now();

      if (await _connectivityService.isOnline) {
        _updateStatus(SyncStatus.success);
      } else {
        _updateStatus(SyncStatus.waitingForNetwork);
      }
    } catch (_) {
      if (await _connectivityService.isOnline) {
        _updateStatus(SyncStatus.syncFailed);
      } else {
        _updateStatus(SyncStatus.waitingForNetwork);
      }
    } finally {
      _syncing = false;
    }
  }

  Future<void> _handleConnectivityChanged(bool online) async {
    if (!online) {
      _updateStatus(SyncStatus.waitingForNetwork);
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
