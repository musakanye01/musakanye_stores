import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/ui/shared/money.dart';

void main() {
  test('formats cents as dollars', () {
    expect(formatUsd(0), '\$0.00');
    expect(formatUsd(5), '\$0.05');
    expect(formatUsd(99), '\$0.99');
    expect(formatUsd(1099), '\$10.99');
    expect(formatUsd(100000), '\$1000.00');
  });

  test('formats negative amounts', () {
    expect(formatUsd(-5), '-\$0.05');
    expect(formatUsd(-1099), '-\$10.99');
  });

  group('parseUsdToCents', () {
    test('parses whole and decimal amounts exactly', () {
      expect(parseUsdToCents('12'), 1200);
      expect(parseUsdToCents('12.5'), 1250);
      expect(parseUsdToCents('12.50'), 1250);
      expect(parseUsdToCents('0.05'), 5);
      expect(parseUsdToCents('0'), 0);
      expect(parseUsdToCents('  7.25  '), 725);
    });

    test('rejects anything that is not a plain amount', () {
      for (final bad in [
        '',
        ' ',
        '.',
        '.5',
        '12.',
        '-1',
        '12.345',
        '1,000',
        'abc',
        '1e3',
        r'$5',
      ]) {
        expect(parseUsdToCents(bad), isNull, reason: 'input: "$bad"');
      }
    });

    test('rejects absurdly large amounts', () {
      expect(parseUsdToCents('9999999999.99'), 999999999999);
      expect(parseUsdToCents('99999999999'), isNull); // 11 digits
    });
  });
}
