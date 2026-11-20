import 'package:drift/drift.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/tables/catalogue_table.dart';
import 'package:pos_tablet/data/local/tables/sale_lines_table.dart';
import 'package:pos_tablet/data/local/tables/sales_table.dart';
import 'package:pos_tablet/data/sync/model/pending_sale_sync.dart';
import 'package:shared_core/domain/model/shift_sales_summary.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [SalesTable, SaleLinesTable, CatalogueTable])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  /// Saves a sale, its lines and stock deductions atomically.
  Future<void> createSaleLocally({
    required SalesTableCompanion sale,
    required List<SaleLinesTableCompanion> lines,
  }) => transaction(() async {
    final saleId = sale.id.value;

    // Prevent duplicate stock deductions on retries.
    final existingSale = await (select(
      salesTable,
    )..where((t) => t.id.equals(saleId))).getSingleOrNull();

    if (existingSale != null) return;

    // Validate all stock before writing anything.
    final stockRows = <String, CatalogueTableData>{};

    for (final line in lines) {
      final variantId = line.variantId.value;
      final quantity = line.quantity.value;

      if (quantity <= 0) {
        throw StateError('Sale quantities must be greater than zero.');
      }

      final stockRow = await (select(
        catalogueTable,
      )..where((t) => t.variantId.equals(variantId))).getSingleOrNull();

      if (stockRow == null) {
        throw StateError(
          'An item is missing from the local catalogue. '
          'Refresh the catalogue before selling.',
        );
      }

      if (stockRow.stockOnHand < quantity) {
        throw StateError(
          'Insufficient cached stock for '
          '${stockRow.productName}.',
        );
      }

      stockRows[variantId] = stockRow;
    }

    // Save the sale header.
    await into(salesTable).insert(sale);

    // Save lines and deduct stock.
    for (final line in lines) {
      await into(saleLinesTable).insert(line);

      final variantId = line.variantId.value;
      final quantity = line.quantity.value;
      final stockRow = stockRows[variantId]!;

      await (update(
        catalogueTable,
      )..where((t) => t.variantId.equals(variantId))).write(
        CatalogueTableCompanion(
          stockOnHand: Value(stockRow.stockOnHand - quantity),
        ),
      );
    }
  });

  //
  /// Live totals for one shift, computed in SQL. Local data only.
  Stream<ShiftSalesSummary> watchShiftSummary(String shiftId) {
    final count = salesTable.id.count();
    final cash = salesTable.totalCents.sum(
      filter: salesTable.paymentMethod.equals('cash'),
    );
    final ecoCash = salesTable.totalCents.sum(
      filter: salesTable.paymentMethod.equals('ecocash_usd'),
    );

    final query = selectOnly(salesTable)
      ..addColumns([count, cash, ecoCash])
      ..where(salesTable.shiftId.equals(shiftId));

    return query
        .map(
          (row) => ShiftSalesSummary(
            salesCount: row.read(count) ?? 0,
            cashSalesCents: row.read(cash) ?? 0,
            ecoCashSalesCents: row.read(ecoCash) ?? 0,
          ),
        )
        .watchSingle();
  }

  /// Returns all lines for a given sale.
  Future<List<SaleLinesTableData>> getLinesForSale(String saleId) =>
      (select(saleLinesTable)..where((t) => t.saleId.equals(saleId))).get();

  /// Marks a sale as successfully synced.
  Future<void> markSynced(String saleId) =>
      (update(salesTable)..where((t) => t.id.equals(saleId))).write(
        const SalesTableCompanion(
          synced: Value(true),
          syncError: Value(false),
          syncErrorMessage: Value(null),
        ),
      );

  /// Records a sync failure.
  Future<void> markSyncFailed(String saleId, String errorMessage) =>
      (update(salesTable)..where((t) => t.id.equals(saleId))).write(
        SalesTableCompanion(
          syncError: const Value(true),
          syncErrorMessage: Value(errorMessage),
        ),
      );

  /// Sales for one shift, newest first. rowid breaks same-second ties.
  Future<List<SalesTableData>> getByShift(
    String shiftId, {
    int limit = 50,
    int offset = 0,
  }) =>
      (select(salesTable)
            ..where((t) => t.shiftId.equals(shiftId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
            ])
            ..limit(limit, offset: offset))
          .get();

  /// Pending sales only.
  Future<List<SalesTableData>> getUnsynced() =>
      (select(salesTable)
            ..where((t) => t.synced.equals(false))
            ..orderBy([
              (t) => OrderingTerm.asc(t.createdAt),
              (t) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
            ]))
          .get();

  Future<SalesTableData?> getSaleById(String id) =>
      (select(salesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Lines with product names from the local catalogue (for receipts).
  Future<List<({SaleLinesTableData line, CatalogueTableData? product})>>
  getLinesWithProducts(String saleId) async {
    final query = select(saleLinesTable).join([
      leftOuterJoin(
        catalogueTable,
        catalogueTable.variantId.equalsExp(saleLinesTable.variantId),
      ),
    ])..where(saleLinesTable.saleId.equals(saleId));

    final rows = await query.get();
    return [
      for (final r in rows)
        (
          line: r.readTable(saleLinesTable),
          product: r.readTableOrNull(catalogueTable),
        ),
    ];
  }

  Future<
    Map<String, List<({SaleLinesTableData line, CatalogueTableData? product})>>
  >
  getLinesWithProductsForSales(List<String> saleIds) async {
    if (saleIds.isEmpty) return {};

    final query =
        select(saleLinesTable).join([
            leftOuterJoin(
              catalogueTable,
              catalogueTable.variantId.equalsExp(saleLinesTable.variantId),
            ),
          ])
          ..where(saleLinesTable.saleId.isIn(saleIds))
          // Qualified: a bare `rowid` is ambiguous in a join.
          ..orderBy([
            OrderingTerm.asc(const CustomExpression<int>('sale_lines.rowid')),
          ]);

    final grouped =
        <
          String,
          List<({SaleLinesTableData line, CatalogueTableData? product})>
        >{};

    for (final r in await query.get()) {
      final line = r.readTable(saleLinesTable);
      grouped.putIfAbsent(line.saleId, () => []).add((
        line: line,
        product: r.readTableOrNull(catalogueTable),
      ));
    }
    return grouped;
  }

  Future<List<PendingSaleSync>> getPendingSalesForSync() async {
    final sales = await getUnsynced();

    final result = <PendingSaleSync>[];

    for (final sale in sales) {
      final lines = await getLinesForSale(sale.id);

      result.add(PendingSaleSync(sale: sale, items: lines));
    }

    return result;
  }
}
