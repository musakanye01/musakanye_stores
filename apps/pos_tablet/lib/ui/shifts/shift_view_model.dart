import 'package:flutter/material.dart';
import 'package:pos_tablet/data/repository/shift_repo.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';

enum ShiftState { unknown, open, none }

class ShiftViewModel extends ChangeNotifier {
  final ShiftRepository _shiftRepository;

  Shift? _currentShift;
  Shift? get currentShift => _currentShift;

  bool _hasLoaded = false;
  bool _isRestoring = false;

  ShiftState get state => !_hasLoaded
      ? ShiftState.unknown
      : (_currentShift != null ? ShiftState.open : ShiftState.none);

  bool _isClosingShift = false;
  bool get isClosingShift => _isClosingShift;

  String? _closeError;
  String? get closeError => _closeError;

  late final Command1<void, int> startShift; // param = opening float in cents

  ShiftViewModel(this._shiftRepository) {
    startShift = Command1(_handleStartShift);
  }

  /// Local-only, idempotent. Drives routing, so it must never touch the network.
  Future<void> restoreShift() async {
    if (_hasLoaded || _isRestoring) return;
    _isRestoring = true;
    try {
      final result = await _shiftRepository.getOpenShift();
      switch (result) {
        case Ok<Shift?>(value: final shift):
          _currentShift = shift;
        case Error<Shift?>(error: final e):
          debugPrint('Could not read local shift: $e');
          _currentShift = null; // don't block routing on a local read failure
      }
      _hasLoaded = true;
      notifyListeners();
    } finally {
      _isRestoring = false;
    }
  }

  Future<Result<void>> _handleStartShift(int openingFloatCents) async {
    final result = await _shiftRepository.startShift(
      openingFloatCents: openingFloatCents,
    );

    switch (result) {
      case Ok<Shift>(value: final shift):
        _currentShift = shift;
        _hasLoaded = true;
        notifyListeners(); // router moves to the dashboard
        return const Result.ok(null);
      case Error<Shift>(error: final err):
        return Result.error(err);
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
          _currentShift = null; // router moves to start-shift
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

  /// Call when the user signs out.
  void reset() {
    if (!_hasLoaded && _currentShift == null) return;
    _currentShift = null;
    _closeError = null;
    _hasLoaded = false;
    notifyListeners();
  }
}
