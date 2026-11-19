import 'package:pos_tablet/data/sync/shift_sync_service.dart';

class OrderedShiftService implements ShiftSyncService {
  OrderedShiftService(this.order);

  final List<String> order;

  @override
  Future<void> syncOpenShifts() async {
    order.add('open');
  }

  @override
  Future<void> syncClosedShifts() async {
    order.add('close');
  }
}
