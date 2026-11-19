import 'package:pos_tablet/data/sync/sale_sync_service.dart';

class OrderedSaleService implements SaleSyncService {
  OrderedSaleService(this.order);

  final List<String> order;

  @override
  Future<void> syncSales() async {
    order.add('sales');
  }
}
