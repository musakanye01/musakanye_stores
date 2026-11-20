import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:pos_tablet/ui/receipt/receipt_view_model.dart';
import 'package:shared_core/domain/model/sale_receipt.dart';

SaleReceipt makeReceipt() => SaleReceipt(
  saleId: 's1',
  createdAt: DateTime(2026, 11, 9, 8, 30),
  paymentMethod: 'cash',
  totalCents: 500,
  tenderedCents: 500,
  lines: const [],
);

class FakeSaleRepository implements SaleRepository {
  SaleReceipt? receipt;
  Object? failWith;
  Completer<void>? gate;
  int calls = 0;

  @override
  Future<SaleReceipt?> getSaleReceipt(String saleId) async {
    calls++;
    await gate?.future;
    if (failWith != null) throw failWith!;
    return receipt;
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('Unexpected call: ${i.memberName}');
}

void main() {
  late FakeSaleRepository repo;
  setUp(() => repo = FakeSaleRepository());

  test('starts in the loading state', () {
    repo.gate = Completer<void>();
    final vm = ReceiptViewModel(repo, 's1');
    addTearDown(vm.dispose);

    expect(vm.isLoading, isTrue);
    expect(vm.receipt, isNull);
  });

  test('loads the receipt', () async {
    repo.receipt = makeReceipt();
    final vm = ReceiptViewModel(repo, 's1');
    addTearDown(vm.dispose);
    await pumpEventQueue();

    expect(vm.isLoading, isFalse);
    expect(vm.receipt?.saleId, 's1');
    expect(vm.errorMessage, isNull);
  });

  test('an unknown sale is not found, not an error', () async {
    repo.receipt = null;
    final vm = ReceiptViewModel(repo, 'missing');
    addTearDown(vm.dispose);
    await pumpEventQueue();

    expect(vm.receipt, isNull);
    expect(vm.errorMessage, isNull);
    expect(vm.isLoading, isFalse);
  });

  test('a read error is reported and retry recovers', () async {
    repo.failWith = Exception('db broke');
    final vm = ReceiptViewModel(repo, 's1');
    addTearDown(vm.dispose);
    await pumpEventQueue();
    expect(vm.errorMessage, isNotNull);
    expect(vm.errorMessage, isNot(contains('connection')));

    repo.failWith = null;
    repo.receipt = makeReceipt();
    await vm.retry();

    expect(vm.errorMessage, isNull);
    expect(vm.receipt, isNotNull);
  });

  test('disposing while a load is in flight does not throw', () async {
    repo.gate = Completer<void>();
    repo.receipt = makeReceipt();
    final vm = ReceiptViewModel(repo, 's1');
    vm.dispose();

    repo.gate!.complete();
    await pumpEventQueue(); // would fail the test if notifyListeners ran after dispose
  });
}
