import 'package:flutter/material.dart';
import 'package:pos_tablet/data/repository/shift_repo.dart';
import 'package:shared_core/domain/shift.dart';
import 'package:shared_core/domain/shift_sales_summary.dart';
import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';
import 'package:uuid/uuid.dart';

class ShiftViewModel extends ChangeNotifier {
  final ShiftRepository _shiftRepository;

  Shift? _currentShift;
  Shift? get currentShift => _currentShift;

  String? _pendingKey;
  int? _pendingCents;

  late final Command1<void, int> startShift; // param = opening float in cents
  late final Command0<void> loadOpenShift;

  ShiftSalesSummary _salesSummary = const ShiftSalesSummary.empty();
  ShiftSalesSummary get salesSummary => _salesSummary;

  bool _isLoadingSummary = false;
  bool get isLoadingSummary => _isLoadingSummary;

  bool _isClosingShift = false;
  bool get isClosingShift => _isClosingShift;

  String? _summaryError;
  String? get summaryError => _summaryError;

  String? _closeError;
  String? get closeError => _closeError;

  ShiftViewModel(this._shiftRepository) {
    startShift = Command1(_handleStartShift);
    loadOpenShift = Command0(_handleLoadOpenShift);
  }

  Future<Result<void>> _handleStartShift(int openingFloatCents) async {
    if (_pendingKey == null || _pendingCents != openingFloatCents) {
      _pendingKey = const Uuid().v4();
      _pendingCents = openingFloatCents;
    }

    final result = await _shiftRepository.startShift(
      openingFloatCents: openingFloatCents,
      idempotencyKey: _pendingKey!,
    );

    switch (result) {
      case Ok<Shift>(value: final shift):
        _currentShift = shift;
        _pendingKey = null;
        _pendingCents = null;
        notifyListeners();
        return const Result.ok(null);
      case Error<Shift>(error: final err):
        return Result.error(err);
    }
  }

  Future<Result<void>> _handleLoadOpenShift() async {
    final result = await _shiftRepository.getOpenShift();
    switch (result) {
      case Ok<Shift?>(value: final shift):
        _currentShift = shift;
        _salesSummary = const ShiftSalesSummary.empty();
        notifyListeners();
        if (shift != null) {
          return await loadSalesSummary();
        }
        return const Result.ok(null);
      case Error<Shift?>(error: final err):
        return Result.error(err);
    }
  }

  Future<Result<void>> loadSalesSummary() async {
    final shift = _currentShift;

    if (shift == null) {
      _salesSummary = const ShiftSalesSummary.empty();
      notifyListeners();
      return const Result.ok(null);
    }

    _isLoadingSummary = true;
    _summaryError = null;
    notifyListeners();

    try {
      final result = await _shiftRepository.getSalesSummary(shift.id);

      switch (result) {
        case Ok<ShiftSalesSummary>(value: final summary):
          _salesSummary = summary;
          _summaryError = null;
          return const Result.ok(null);

        case Error<ShiftSalesSummary>(error: final err):
          _summaryError = err.toString();
          return Result.error(err);
      }
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<Result<void>> closeCurrentShift({
    required int countedCashCents,
    String? closingNote,
  }) async {
    final shift = _currentShift;

    if (shift == null || shift.status != 'open') {
      return Result.error(Exception('There is no open shift to close.'));
    }

    if (_isClosingShift) {
      return Result.error(Exception('Shift closing is already in progress.'));
    }

    _isClosingShift = true;
    _closeError = null;
    notifyListeners();

    try {
      final result = await _shiftRepository.closeShift(
        shiftId: shift.id,
        countedCashCents: countedCashCents,
        closingNote: closingNote,
      );

      switch (result) {
        case Ok<void>():
          _currentShift = null;
          _salesSummary = const ShiftSalesSummary.empty();
          return const Result.ok(null);

        case Error<void>(error: final err):
          _closeError = err.toString();
          return Result.error(err);
      }
    } finally {
      _isClosingShift = false;
      notifyListeners();
    }
  }
}
