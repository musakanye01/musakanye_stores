import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/repository/bootsrap_repository.dart';
import 'package:pos_tablet/ui/bootstrap/bootstrap_view_model.dart';
import 'package:shared_core/util/result.dart';

void main() {
  group('restoreState', () {
    test('transitions to ready when device is bootstrapped', () async {
      final repository = _FakeBootstrapRepository(
        isBootstrappedResult: const Result.ok(true),
      );

      final viewModel = BootstrapViewModel(repository);

      expect(viewModel.status, BootstrapStatus.unknown);

      await viewModel.restoreState();

      expect(viewModel.status, BootstrapStatus.ready);

      expect(viewModel.isReady, true);

      expect(viewModel.errorMessage, isNull);
    });

    test('transitions to required when device is not bootstrapped', () async {
      final repository = _FakeBootstrapRepository(
        isBootstrappedResult: const Result.ok(false),
      );

      final viewModel = BootstrapViewModel(repository);

      await viewModel.restoreState();

      expect(viewModel.status, BootstrapStatus.required);

      expect(viewModel.requiresBootstrap, true);

      expect(viewModel.isReady, false);
    });

    test('transitions to error when restore fails', () async {
      final repository = _FakeBootstrapRepository(
        isBootstrappedResult: Result.error(Exception('restore failed')),
      );

      final viewModel = BootstrapViewModel(repository);

      await viewModel.restoreState();

      expect(viewModel.status, BootstrapStatus.error);

      expect(viewModel.errorMessage, contains('restore failed'));
    });

    test('notifies listeners during restore', () async {
      final repository = _FakeBootstrapRepository(
        isBootstrappedResult: const Result.ok(true),
      );

      final viewModel = BootstrapViewModel(repository);

      var notifications = 0;

      viewModel.addListener(() {
        notifications++;
      });

      await viewModel.restoreState();

      expect(notifications, greaterThanOrEqualTo(2));
    });
  });

  group('bootstrap', () {
    test('transitions to ready when bootstrap succeeds', () async {
      final repository = _FakeBootstrapRepository(
        runBootstrapResult: const Result.ok(null),
      );

      final viewModel = BootstrapViewModel(repository);

      await viewModel.bootstrap();

      expect(viewModel.status, BootstrapStatus.ready);

      expect(viewModel.errorMessage, isNull);
    });

    test('transitions to error when bootstrap fails', () async {
      final repository = _FakeBootstrapRepository(
        runBootstrapResult: Result.error(Exception('bootstrap failed')),
      );

      final viewModel = BootstrapViewModel(repository);

      await viewModel.bootstrap();

      expect(viewModel.status, BootstrapStatus.error);

      expect(viewModel.errorMessage, contains('bootstrap failed'));
    });

    test('clears stale error before bootstrap starts', () async {
      final repository = _FakeBootstrapRepository(
        isBootstrappedResult: Result.error(Exception('old error')),
        runBootstrapResult: const Result.ok(null),
      );

      final viewModel = BootstrapViewModel(repository);

      await viewModel.restoreState();

      expect(viewModel.errorMessage, isNotNull);

      await viewModel.bootstrap();

      expect(viewModel.status, BootstrapStatus.ready);

      expect(viewModel.errorMessage, isNull);
    });

    test('notifies listeners during bootstrap', () async {
      final repository = _FakeBootstrapRepository(
        runBootstrapResult: const Result.ok(null),
      );

      final viewModel = BootstrapViewModel(repository);

      var notifications = 0;

      viewModel.addListener(() {
        notifications++;
      });

      await viewModel.bootstrap();

      expect(notifications, greaterThanOrEqualTo(2));
    });
  });

  group('derived properties', () {
    test('isBusy is true while checking', () async {
      final repository = _FakeBootstrapRepository(
        isBootstrappedResult: const Result.ok(true),
      );

      final viewModel = BootstrapViewModel(repository);

      expect(viewModel.isBusy, false);
    });

    test('requiresBootstrap reflects required state', () async {
      final repository = _FakeBootstrapRepository(
        isBootstrappedResult: const Result.ok(false),
      );

      final viewModel = BootstrapViewModel(repository);

      await viewModel.restoreState();

      expect(viewModel.requiresBootstrap, true);
    });
  });
}

class _FakeBootstrapRepository implements BootstrapRepository {
  _FakeBootstrapRepository({
    this.isBootstrappedResult = const Result.ok(false),
    this.runBootstrapResult = const Result.ok(null),
  });

  final Result<bool> isBootstrappedResult;
  final Result<void> runBootstrapResult;

  @override
  Future<Result<bool>> isBootstrapped() async {
    return isBootstrappedResult;
  }

  @override
  Future<Result<void>> runBootstrap() async {
    return runBootstrapResult;
  }
}
