import 'package:pos_tablet/data/local/app_database.dart';

class PendingSaleSync {
  const PendingSaleSync({required this.sale, required this.items});

  final SalesTableData sale;

  final List<SaleLinesTableData> items;
}
