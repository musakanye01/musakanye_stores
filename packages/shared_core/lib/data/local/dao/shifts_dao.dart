import 'package:drift/drift.dart';
import 'package:shared_core/data/local/app_database.dart';
import 'package:shared_core/data/local/tables/shifts_table.dart';
import 'package:shared_core/domain/model/shift.dart';

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

  /// True when a locally closed shift has not yet been confirmed by Supabase.
  /// This prevents a stale remote open shift from being restored after an
  /// offline close.
  Future<bool> hasPendingClose(String cashierId) async {
    final row =
        await (select(shiftsTable)
              ..where(
                (t) =>
                    t.cashierId.equals(cashierId) &
                    t.status.equals('closed') &
                    t.synced.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Returns a shift by its local ID.
  Future<ShiftsTableData?> getById(String shiftId) => (select(
    shiftsTable,
  )..where((t) => t.id.equals(shiftId))).getSingleOrNull();

  /// Inserts or updates a shift row.
  Future<void> upsertShift(ShiftsTableCompanion row) =>
      into(shiftsTable).insertOnConflictUpdate(row);

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
      synced: const Value(false),
      syncError: const Value(false),
      syncErrorMessage: const Value(null),
    ),
  );

  /// Returns all rows that still need to be pushed to Supabase.
  Future<List<ShiftsTableData>> getUnsynced() =>
      (select(shiftsTable)..where((t) => t.synced.equals(false))).get();

  /// Marks a shift as successfully synced.
  Future<void> markSynced(String shiftId) =>
      (update(shiftsTable)..where((t) => t.id.equals(shiftId))).write(
        const ShiftsTableCompanion(
          synced: Value(true),
          syncError: Value(false),
          syncErrorMessage: Value(null),
        ),
      );

  /// Records a sync failure with the server error message.
  Future<void> markSyncFailed(String shiftId, String errorMessage) =>
      (update(shiftsTable)..where((t) => t.id.equals(shiftId))).write(
        ShiftsTableCompanion(
          syncError: const Value(true),
          syncErrorMessage: Value(errorMessage),
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
    closingFloatCents: row.closingCountedCents,
  );
}
