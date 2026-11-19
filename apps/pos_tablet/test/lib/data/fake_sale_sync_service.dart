import 'package:pos_tablet/data/sync/sale_sync_service.dart';

class FakeSaleSyncService implements SaleSyncService {
  final calls = <String>[];

  @override
  Future<void> syncSales() async {
    calls.add('sales');
  }
}
