import 'dart:async';

import 'package:pos_tablet/data/sync/connectivity_service.dart';

class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({required this.online});

  final bool online;

  final controller = StreamController<bool>.broadcast();

  @override
  Future<bool> get isOnline async => online;

  @override
  Stream<bool> get onlineChanges => controller.stream;
}
