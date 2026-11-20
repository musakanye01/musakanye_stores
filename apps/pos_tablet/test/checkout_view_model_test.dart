import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:pos_tablet/ui/sale/model/cart_item.dart';
import 'package:pos_tablet/ui/checkout/checkout_view_model.dart';
import 'package:shared_core/domain/model/sale_line.dart'; // SaleLine, SaleResult
import 'package:shared_core/util/result.dart';

class SaleCall {
  SaleCall(
    this.saleId,
    this.idempotencyKey,
    this.shiftId,
    this.paymentMethod,
    this.items,
    this.tenderedCents,
  );
  final String saleId;
  final String idempotencyKey;
  final String shiftId;
  final String paymentMethod;
  final List<SaleLine> items;
  final int tenderedCents;
}

class FakeSaleRepository implements SaleRepository {
  final calls = <SaleCall>[];
  Result<SaleResult>? nextResult; // null = succeed

  @override
  Future<Result<SaleResult>> createSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required String paymentMethod,
    required List<SaleLine> items,
    required int tenderedCents,
  }) async {
    calls.add(
      SaleCall(
        saleId,
        idempotencyKey,
        shiftId,
        paymentMethod,
        items,
        tenderedCents,
      ),
    );
    final total = items.fold<int>(
      0,
      (s, l) => s + (l.unitPriceCents ?? 0) * l.quantity,
    );
    return nextResult ??
        Result.ok(
          SaleResult(saleId: saleId, totalCents: total, duplicate: false),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected call: ${invocation.memberName}');
}

CartItem line(String id, {int price = 500, int qty = 1}) => CartItem(
  variantId: id,
  name: 'Item $id',
  unitPriceCents: price,
  availableStock: 99,
  quantity: qty,
);

CheckoutInput input(
  List<CartItem> items, {
  int tendered = 10000,
  String method = 'cash',
}) => CheckoutInput(
  shiftId: 'shift-1',
  items: items,
  tenderedCents: tendered,
  paymentMethod: method,
);

void main() {
  late FakeSaleRepository repo;
  late CheckoutViewModel vm;

  setUp(() {
    repo = FakeSaleRepository();
    vm = CheckoutViewModel(repo);
  });
  tearDown(() => vm.dispose());

  test('success sends exact cents and exposes lastSale', () async {
    await vm.completeSale.execute(input([line('a', price: 1099, qty: 2)]));

    expect(repo.calls, hasLength(1));
    final sent = repo.calls.single.items.single;
    expect(sent.unitPriceCents, 1099);
    expect(sent.quantity, 2);
    expect(vm.lastSale?.totalCents, 2198);
  });

  test('an empty cart never reaches the repository', () async {
    await vm.completeSale.execute(input([]));
    expect(repo.calls, isEmpty);
    expect(vm.lastSale, isNull);
  });

  test(
    'retrying the same cart after a failure reuses the sale id and key',
    () async {
      final cart = [line('a'), line('b')];

      repo.nextResult = Result.error(Exception('disk full'));
      await vm.completeSale.execute(input(cart));

      repo.nextResult = null;
      await vm.completeSale.execute(input(cart));

      expect(repo.calls, hasLength(2));
      expect(repo.calls[1].saleId, repo.calls[0].saleId);
      expect(repo.calls[1].idempotencyKey, repo.calls[0].idempotencyKey);
    },
  );

  test(
    'the same items in a different order still count as the same cart',
    () async {
      repo.nextResult = Result.error(Exception('disk full'));
      await vm.completeSale.execute(input([line('a'), line('b')]));

      repo.nextResult = null;
      await vm.completeSale.execute(input([line('b'), line('a')]));

      expect(repo.calls[1].saleId, repo.calls[0].saleId);
    },
  );

  test('a changed cart after a failure gets a new sale id', () async {
    repo.nextResult = Result.error(Exception('disk full'));
    await vm.completeSale.execute(input([line('a')]));

    repo.nextResult = null;
    await vm.completeSale.execute(input([line('a', qty: 2)]));

    expect(repo.calls[1].saleId, isNot(repo.calls[0].saleId));
    expect(repo.calls[1].idempotencyKey, isNot(repo.calls[0].idempotencyKey));
  });

  test('after a success, an identical cart is a new sale', () async {
    final cart = [line('a')];
    await vm.completeSale.execute(input(cart));
    await vm.completeSale.execute(input(cart));

    expect(repo.calls, hasLength(2));
    expect(repo.calls[1].saleId, isNot(repo.calls[0].saleId));
  });

  test('a double tap can never produce two different sale ids', () async {
    final cart = [line('a')];
    final first = vm.completeSale.execute(input(cart));
    final second = vm.completeSale.execute(input(cart));
    await Future.wait([first, second]);

    // Either the command ignored the second tap, or both used the same id.
    // Both are safe, because createSaleLocally skips an id it already has.
    expect(repo.calls.map((c) => c.saleId).toSet(), hasLength(1));
  });
}
