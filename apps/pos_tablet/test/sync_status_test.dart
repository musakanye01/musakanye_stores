import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/domain/model/sync_status.dart';

void main() {
  test('synced wins', () {
    expect(syncStatusOf(synced: true, syncError: false), SyncStatus.synced);
    expect(syncStatusOf(synced: true, syncError: true), SyncStatus.synced);
  });
  test('unsynced with an error is failed', () {
    expect(syncStatusOf(synced: false, syncError: true), SyncStatus.failed);
  });
  test('unsynced without an error is pending', () {
    expect(syncStatusOf(synced: false, syncError: false), SyncStatus.pending);
  });
}
