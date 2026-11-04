import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_tablet/data/repository/shift_summary_repo.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:shared_core/domain/model/shift_sales_summary.dart';

class ShiftSummaryViewModel extends ChangeNotifier {
  ShiftSummaryViewModel(this._repository, this._shift) {
    _shift.addListener(_onShiftChanged);
    _onShiftChanged(); // the shift may already be open when we're created
  }

  final ShiftSummaryRepository _repository;
  final ShiftViewModel _shift;

  StreamSubscription<ShiftSalesSummary>? _subscription;
  String? _boundShiftId;

  ShiftSalesSummary _summary = const ShiftSalesSummary.empty();
  ShiftSalesSummary get summary => _summary;

  Object? _error;
  Object? get error => _error;

  /// Opening float plus cash sales for the current shift.
  int get expectedCashCents =>
      (_shift.currentShift?.openingFloatCents ?? 0) + _summary.cashSalesCents;

  void _onShiftChanged() {
    final id = _shift.currentShift?.id;
    if (id == _boundShiftId) {
      return; // ShiftViewModel notified for another reason
    }

    _boundShiftId = id;
    _subscription?.cancel();
    _subscription = null;
    _summary = const ShiftSalesSummary.empty();
    _error = null;

    if (id != null) {
      _subscription = _repository
          .watchSummary(id)
          .listen(
            (value) {
              _summary = value;
              _error = null;
              notifyListeners();
            },
            onError: (Object e) {
              _error = e;
              notifyListeners();
            },
          );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _shift.removeListener(_onShiftChanged);
    _subscription?.cancel();
    super.dispose();
  }
}
