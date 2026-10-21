import 'package:flutter/foundation.dart';
import 'package:owner/data/repo/dashboard_repo.dart';
import 'package:shared_core/domain/model/dashboard_summary.dart';
import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._repository) {
    load = Command0(_load);
    load.execute();
  }

  final DashboardRepository _repository;

  late final Command0<void> load;

  DashboardSummary? _summary;
  DashboardSummary? get summary => _summary;

  Future<Result<void>> _load() async {
    final result = await _repository.getSummary();
    switch (result) {
      case Ok<DashboardSummary>(value: final summary):
        _summary = summary;
        notifyListeners();
        return const Result.ok(null);
      case Error<DashboardSummary>(error: final err):
        return Result.error(err);
    }
  }

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }
}
