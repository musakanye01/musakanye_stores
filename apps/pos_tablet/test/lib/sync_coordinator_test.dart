import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/sync/sync_coordinator.dart';

import 'data/counting_shift_service.dart';
import 'data/fake_connectivity_service.dart';
import 'data/fake_sale_sync_service.dart';
import 'data/fake_shift_sync_service.dart';
import 'data/ordered_sale_service.dart';
import 'data/ordered_shift_service.dart';

void main() {
  test('initialize enters waitingForNetwork when offline', () async {
    final coordinator = SyncCoordinatorImp(
      shiftSyncService: FakeShiftSyncService(),
      connectivityService: FakeConnectivityService(online: false),
      salesSyncService: FakeSaleSyncService(),
    );

    await coordinator.initialize();

    expect(coordinator.status, SyncStatus.waitingForNetwork);
  });

  test('initialize triggers sync when online', () async {
    final shift = FakeShiftSyncService();

    final sales = FakeSaleSyncService();

    final coordinator = SyncCoordinatorImp(
      shiftSyncService: shift,
      connectivityService: FakeConnectivityService(online: true),
      salesSyncService: sales,
    );

    await coordinator.initialize();

    await Future<void>.delayed(Duration.zero);

    expect(shift.calls, ['open', 'close']);

    expect(sales.calls, ['sales']);
  });

  test('pipeline order is open sales close', () async {
    final order = <String>[];

    final shift = OrderedShiftService(order);

    final sales = OrderedSaleService(order);

    final coordinator = SyncCoordinatorImp(
      shiftSyncService: shift,
      connectivityService: FakeConnectivityService(online: false),
      salesSyncService: sales,
    );

    await coordinator.triggerSync();

    expect(order, ['open', 'sales', 'close']);
  });

  test('online transition triggers sync', () async {
    final shift = FakeShiftSyncService();

    final sales = FakeSaleSyncService();

    var fakeConnectivityService = FakeConnectivityService(online: false);
    final coordinator = SyncCoordinatorImp(
      shiftSyncService: shift,
      connectivityService: fakeConnectivityService,
      salesSyncService: sales,
    );

    await coordinator.initialize();

    fakeConnectivityService.controller.add(true);

    await Future<void>.delayed(Duration.zero);

    expect(shift.calls, contains('open'));

    expect(sales.calls, contains('sales'));
  });

  test('concurrent triggerSync only runs once', () async {
    final shift = CountingShiftService();

    final sales = FakeSaleSyncService();

    final coordinator = SyncCoordinatorImp(
      shiftSyncService: shift,
      connectivityService: FakeConnectivityService(online: true),
      salesSyncService: sales,
    );

    await Future.wait([
      coordinator.triggerSync(),
      coordinator.triggerSync(),
      coordinator.triggerSync(),
    ]);

    expect(shift.openCalls, 1);
  });
}
