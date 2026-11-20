import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:pos_tablet/ui/sale_history/viewmodel/sales_history_view_model.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/util/result.dart';

import 'lib/data/fake_shift_repo.dart';

SaleHistory sale(String id, {String method = 'cash', int total = 100}) =>
    SaleHistory.fromJson({
      'id': id,
      'cashier_id': '',
      'total_cents': total,
      'status': 'completed',
      'created_at': DateTime.utc(2026, 11, 9).toIso8601String(),
      'payment_method': method,
    });

class FakeSaleRepository implements SaleRepository {
  final calls = <({String shiftId, int offset, int limit})>[];
  Map<String, List<SaleHistory>> byShift = {};
  Completer<void>? gate; // holds a load in flight
  Object? failWith;

  @override
  Future<List<SaleHistory>> getSalesHistory({
    required String shiftId,
    int offset = 0,
    int limit = 50,
  }) async {
    calls.add((shiftId: shiftId, offset: offset, limit: limit));
    await gate?.future;
    if (failWith != null) throw failWith!;
    return (byShift[shiftId] ?? []).skip(offset).take(limit).toList();
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('Unexpected call: ${i.memberName}');
}

void main() {
  late FakeShiftRepository shiftRepo;
  late ShiftViewModel shiftVm;
  late FakeSaleRepository saleRepo;
  late SalesHistoryViewModel vm;

  setUp(() {
    shiftRepo = FakeShiftRepository();
    shiftVm = ShiftViewModel(shiftRepo);
    saleRepo = FakeSaleRepository();
    vm = SalesHistoryViewModel(saleRepo, shiftVm);
  });
  tearDown(() => vm.dispose());

  Future<void> openShift(String id) async {
    shiftRepo.openShiftResult = Result.ok(shiftFixture(id, 1000));
    shiftVm.reset();
    await shiftVm.restoreShift();
    await pumpEventQueue();
  }

  test('with no shift it is empty and never calls the repository', () async {
    await vm.loadInitial(); // e.g. the screen opened before a shift exists
    expect(vm.sales, isEmpty);
    expect(saleRepo.calls, isEmpty);
  });

  test('opening a shift loads that shift\'s sales', () async {
    saleRepo.byShift = {
      's1': [sale('a'), sale('b')],
    };
    await openShift('s1');

    expect(saleRepo.calls.single.shiftId, 's1');
    expect(vm.sales.map((s) => s.id), ['a', 'b']);
  });

  test('closing the shift clears the list', () async {
    saleRepo.byShift = {
      's1': [sale('a')],
    };
    await openShift('s1');

    await shiftVm.closeCurrentShift(countedCashCents: 0);
    await pumpEventQueue();

    expect(vm.sales, isEmpty);
    expect(vm.hasMore, isFalse);
  });

  test('a different shift replaces the list, never mixes', () async {
    saleRepo.byShift = {
      's1': [sale('a')],
      's2': [sale('z')],
    };
    await openShift('s1');
    await openShift('s2');

    expect(vm.sales.map((s) => s.id), ['z']);
  });

  test('unrelated ShiftViewModel notifications do not reload', () async {
    saleRepo.byShift = {
      's1': [sale('a')],
    };
    await openShift('s1');
    final before = saleRepo.calls.length;

    shiftRepo.closeResult = Result.error(Exception('disk full'));
    await shiftVm.closeCurrentShift(
      countedCashCents: 0,
    ); // notifies, same shift
    await pumpEventQueue();

    expect(saleRepo.calls.length, before);
    expect(vm.sales, hasLength(1));
  });

  test('a slow response for an old shift is ignored', () async {
    saleRepo.byShift = {
      's1': [sale('old')],
      's2': [sale('new')],
    };

    saleRepo.gate = Completer<void>();
    await openShift('s1'); // this load hangs

    final slow = saleRepo.gate!;
    saleRepo.gate = null;
    await openShift('s2'); // must not be blocked by the hanging s1 load
    expect(vm.sales.map((s) => s.id), ['new']);
    expect(vm.isLoading, isFalse);

    slow.complete(); // the old response finally arrives
    await pumpEventQueue();

    expect(vm.sales.map((s) => s.id), ['new']);
    expect(vm.isLoading, isFalse);
  });

  group('paging', () {
    setUp(() async {
      saleRepo.byShift = {
        's1': [for (var i = 0; i < 5; i++) sale('s$i')],
      };
      await openShift('s1');
      vm.pageSize = 2;
      await vm.loadInitial();
    });

    test('loadInitial loads one page', () {
      expect(vm.sales, hasLength(2));
      expect(vm.hasMore, isTrue);
    });

    test('loadMore appends pages and stops at the end', () async {
      await vm.loadMore();
      await vm.loadMore();

      expect(vm.sales.map((s) => s.id), ['s0', 's1', 's2', 's3', 's4']);
      expect(vm.hasMore, isFalse);

      final calls = saleRepo.calls.length;
      await vm.loadMore(); // nothing left, so no call
      expect(saleRepo.calls.length, calls);
    });

    test('overlapping loadMore calls fetch one page', () async {
      saleRepo.gate = Completer<void>();
      final first = vm.loadMore();
      final second = vm.loadMore(); // dropped: one is already loading
      saleRepo.gate!.complete();
      await Future.wait([first, second]);

      expect(vm.sales, hasLength(4));
    });

    test('a failed loadMore keeps the list and reports the error', () async {
      saleRepo.failWith = Exception('db broke');
      await vm.loadMore();

      expect(vm.sales, hasLength(2));
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoadingMore, isFalse);
      expect(vm.hasMore, isTrue); // retryable
    });
  });

  test('a failed initial load reports a local-storage message', () async {
    saleRepo.failWith = Exception('db broke');
    await openShift('s1');

    expect(vm.errorMessage, isNotNull);
    expect(vm.errorMessage, isNot(contains('connection')));
    expect(vm.isLoading, isFalse);
  });

  test(
    're-entering the screen reloads page one without emptying first',
    () async {
      saleRepo.byShift = {
        's1': [sale('a')],
      };
      await openShift('s1');

      saleRepo.byShift = {
        's1': [sale('b'), sale('a')],
      };
      saleRepo.gate = Completer<void>();
      final reload = vm.loadInitial();
      expect(vm.sales.map((s) => s.id), ['a']); // old list still visible

      saleRepo.gate!.complete();
      await reload;
      expect(vm.sales.map((s) => s.id), ['b', 'a']);
    },
  );

  group('search', () {
    setUp(() async {
      saleRepo.byShift = {
        's1': [
          sale('abc-1', method: 'cash', total: 500),
          sale('xyz-2', method: 'ecocash_usd', total: 1250),
        ],
      };
      await openShift('s1');
    });

    test('matches payment method, id, and amount in cents', () {
      vm.setSearchQuery('ecocash');
      expect(vm.filteredSales.map((s) => s.id), ['xyz-2']);

      vm.setSearchQuery('ABC'); // case-insensitive
      expect(vm.filteredSales.map((s) => s.id), ['abc-1']);

      vm.setSearchQuery('1250');
      expect(vm.filteredSales.map((s) => s.id), ['xyz-2']);
    });

    test('blank query returns everything', () {
      vm.setSearchQuery('   ');
      expect(vm.filteredSales, hasLength(2));
    });

    test(
      'switching shift keeps the typed query but not the old results',
      () async {
        vm.setSearchQuery('cash');
        saleRepo.byShift = {
          's2': [sale('q', method: 'cash')],
        };
        await openShift('s2');

        expect(vm.searchQuery, 'cash');
        expect(vm.filteredSales.map((s) => s.id), ['q']);
      },
    );
  });

  test('dispose removes the listener from ShiftViewModel', () async {
    final local = SalesHistoryViewModel(saleRepo, shiftVm);
    local.dispose();

    saleRepo.byShift = {
      's1': [sale('a')],
    };
    final before = saleRepo.calls.length;
    await openShift('s1');

    expect(saleRepo.calls.length, before + 1); // only the shared vm loaded
  });
}
