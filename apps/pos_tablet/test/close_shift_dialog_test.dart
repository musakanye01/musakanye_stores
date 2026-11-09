import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/ui/shifts/close_shift_dialog.dart';

void main() {
  CloseShiftDetails? result;
  var resolved = false;

  Future<void> openDialog(WidgetTester tester) async {
    result = null;
    resolved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await CloseShiftDialog.show(context);
                  resolved = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  const invalidMessage = 'Enter a valid amount with up to 2 decimals.';

  testWidgets('returns counted cents and a trimmed note', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField).first, '12.50');
    await tester.enterText(find.byType(TextFormField).last, '  all good  ');
    await tester.tap(find.text('Confirm Close'));
    await tester.pumpAndSettle();

    expect(result?.countedCashCents, 1250);
    expect(result?.note, 'all good');
  });

  testWidgets('a blank note comes back as null', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField).first, '5');
    await tester.tap(find.text('Confirm Close'));
    await tester.pumpAndSettle();

    expect(result?.countedCashCents, 500);
    expect(result?.note, isNull);
  });

  testWidgets('a zero count is allowed', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.tap(find.text('Confirm Close'));
    await tester.pumpAndSettle();

    expect(result?.countedCashCents, 0);
  });

  for (final bad in ['', '12.345', '-5', 'abc']) {
    testWidgets('rejects "$bad" and keeps the dialog open', (tester) async {
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).first, bad);
      await tester.tap(find.text('Confirm Close'));
      await tester.pumpAndSettle();

      expect(find.text(invalidMessage), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(resolved, isFalse);
    });
  }

  testWidgets('cancel returns null', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(resolved, isTrue);
    expect(result, isNull);
  });
}
