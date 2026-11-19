import 'package:drift/drift.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/tables/shifts_table.dart';

import 'package:shared_core/domain/model/shift.dart';
import 'package:uuid/uuid.dart';

part 'shifts_dao.g.dart';

@DriftAccessor(tables: [ShiftsTable])
class ShiftsDao extends DatabaseAccessor<AppDatabase> with _$ShiftsDaoMixin {
  ShiftsDao(super.db);

  /// Returns the currently open shift for [cashierId], or null.
  Future<ShiftsTableData?> getOpenShift(String cashierId) =>
      (select(shiftsTable)
            ..where(
              (t) => t.cashierId.equals(cashierId) & t.status.equals('open'),
            )
            ..limit(1))
          .getSingleOrNull();

  /// Returns false (and inserts nothing) if the cashier already has an open shift.
  Future<bool> insertIfNoneOpen(ShiftsTableCompanion shift, String cashierId) {
    return transaction(() async {
      if (await getOpenShift(cashierId) != null) return false;
      await upsertShift(shift);
      return true;
    });
  }

  /// Returns a shift by its local ID.
  Future<ShiftsTableData?> getById(String shiftId) => (select(
    shiftsTable,
  )..where((t) => t.id.equals(shiftId))).getSingleOrNull();

  /// Inserts or updates a shift row.
  Future<void> upsertShift(ShiftsTableCompanion row) =>
      into(shiftsTable).insertOnConflictUpdate(row);

  Future<void> markCloseSynced(String shiftId) =>
      (update(shiftsTable)..where((t) => t.id.equals(shiftId))).write(
        const ShiftsTableCompanion(
          closeSynced: Value(true),
          syncError: Value(false),
          syncErrorMessage: Value(null),
        ),
      );

  Future<void> markSyncFailed(String shiftId, String errorMessage) =>
      (update(shiftsTable)..where((t) => t.id.equals(shiftId))).write(
        ShiftsTableCompanion(
          syncError: const Value(true),
          syncErrorMessage: Value(errorMessage),
        ),
      );

  Future<void> markOpenSynced(String shiftId) =>
      (update(shiftsTable)..where((t) => t.id.equals(shiftId))).write(
        const ShiftsTableCompanion(
          openSynced: Value(true),
          syncError: Value(false),
          syncErrorMessage: Value(null),
        ),
      );

  Future<List<ShiftsTableData>> getUnsyncedOpenShifts() {
    return (select(
      shiftsTable,
    )..where((t) => t.openSynced.equals(false))).get();
  }

  Future<List<ShiftsTableData>> getUnsyncedClosedShifts() {
    return (select(
      shiftsTable,
    )..where((t) => t.synced.equals(false) & t.status.equals('closed'))).get();
  }

  /// Marks a shift as closed locally.
  Future<void> markClosed({
    required String shiftId,
    required int countedCashCents,
    String? closingNote,
  }) => (update(shiftsTable)..where((t) => t.id.equals(shiftId))).write(
    ShiftsTableCompanion(
      status: const Value('closed'),
      closingCountedCents: Value(countedCashCents),
      closingNote: Value(closingNote),
      closedAt: Value(DateTime.now().toUtc()),
      closeIdempotencyKey: Value(const Uuid().v4()),
      closeSynced: const Value(false),
      syncError: const Value(false),
      syncErrorMessage: const Value(null),
    ),
  );

  /// Converts a Drift row to the domain [Shift] model.
  static Shift toDomain(ShiftsTableData row) => Shift(
    id: row.id,
    cashierId: row.cashierId,
    deviceId: null,
    openingFloatCents: row.openingFloatCents,
    status: row.status,
    openedAt: row.openedAt,
    closedAt: row.closedAt,
    closingFloatCents: row.closingCountedCents,
  );
}
