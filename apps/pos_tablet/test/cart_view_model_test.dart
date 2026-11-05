import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/ui/sales/cart_item.dart';
import 'package:pos_tablet/ui/sales/viewmodel/cart_view_model.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

CatalogueItem item(
  String id, {
  int price = 500,
  int stock = 5,
  String name = 'Shirt',
}) => CatalogueItem(
  variantId: id,
  productId: 'p-$id',
  productName: name,
  categoryName: 'Tops',
  sku: 'SKU-$id',
  size: 'M',
  colour: 'Blue',
  priceCents: price,
  stockOnHand: stock,
  description: '',
  categoryId: 'cat-1',
);

void main() {
  late CartViewModel cart;

  setUp(() => cart = CartViewModel());
  tearDown(() => cart.dispose());

  test('starts empty', () {
    expect(cart.isEmpty, isTrue);
    expect(cart.itemCount, 0);
    expect(cart.totalCents, 0);
    expect(cart.quantityOf('anything'), 0);
  });

  group('add', () {
    test('a new item becomes a line with its price in cents', () {
      expect(cart.add(item('a', price: 1099)), isTrue);

      expect(cart.items, hasLength(1));
      expect(cart.items.single.variantId, 'a');
      expect(cart.items.single.unitPriceCents, 1099);
      expect(cart.items.single.quantity, 1);
      expect(cart.totalCents, 1099);
    });

    test('adding the same item again increases its quantity', () {
      cart.add(item('a'));
      cart.add(item('a'));

      expect(cart.items, hasLength(1));
      expect(cart.quantityOf('a'), 2);
    });

    test('different variants stay on separate lines', () {
      cart.add(item('a'));
      cart.add(item('b'));

      expect(cart.items, hasLength(2));
      expect(cart.itemCount, 2);
    });

    test('is refused for an out-of-stock item', () {
      expect(cart.add(item('a', stock: 0)), isFalse);
      expect(cart.isEmpty, isTrue);
    });

    test('is refused once the cart holds all available stock', () {
      cart.add(item('a', stock: 2));
      cart.add(item('a', stock: 2));

      expect(cart.add(item('a', stock: 2)), isFalse);
      expect(cart.quantityOf('a'), 2);
    });

    test('uses the fresher stock figure when the item is added again', () {
      cart.add(item('a', stock: 5));

      // The catalogue now says only 1 is left, and 1 is already in the cart.
      expect(cart.add(item('a', stock: 1)), isFalse);
      expect(cart.quantityOf('a'), 1);
    });
  });

  group('increase and decrease', () {
    test('increase stops at the stock seen when the item was added', () {
      cart.add(item('a', stock: 2));

      expect(cart.increase('a'), isTrue);
      expect(cart.increase('a'), isFalse);
      expect(cart.quantityOf('a'), 2);
    });

    test('increase on an unknown item does nothing', () {
      expect(cart.increase('missing'), isFalse);
    });

    test('decrease lowers the quantity', () {
      cart.add(item('a'));
      cart.increase('a');

      cart.decrease('a');
      expect(cart.quantityOf('a'), 1);
    });

    test('decrease at quantity 1 removes the line', () {
      cart.add(item('a'));
      cart.decrease('a');
      expect(cart.isEmpty, isTrue);
    });
  });

  group('remove and clear', () {
    test('remove drops the whole line', () {
      cart.add(item('a'));
      cart.increase('a');
      cart.add(item('b'));

      cart.remove('a');
      expect(cart.items.map((i) => i.variantId), ['b']);
    });

    test('clear empties the cart', () {
      cart.add(item('a'));
      cart.add(item('b'));

      cart.clear();
      expect(cart.isEmpty, isTrue);
      expect(cart.totalCents, 0);
    });
  });

  group('totals', () {
    test('are exact integer cents across lines and quantities', () {
      cart.add(item('a', price: 1099, stock: 10));
      cart.increase('a');
      cart.increase('a'); // 3 x 1099
      cart.add(item('b', price: 333, stock: 10));

      expect(cart.totalCents, 1099 * 3 + 333);
      expect(cart.itemCount, 4);
    });

    test('line totals are price times quantity', () {
      cart.add(item('a', price: 250, stock: 10));
      cart.increase('a');
      expect(cart.items.single.totalCents, 500);
    });
  });

  group('notifications', () {
    test('listeners are told about real changes only', () {
      var notified = 0;
      cart.addListener(() => notified++);

      cart.add(item('a', stock: 1)); // changes
      cart.add(item('a', stock: 1)); // refused: no change
      cart.increase('missing'); // no change
      cart.clear(); // changes
      cart.clear(); // already empty: no change

      expect(notified, 2);
    });
  });

  test('items cannot be modified from outside', () {
    cart.add(item('a'));
    expect(
      () => cart.items.add(
        const CartItem(
          variantId: 'x',
          name: 'x',
          unitPriceCents: 1,
          availableStock: 1,
        ),
      ),
      throwsUnsupportedError,
    );
  });
}
