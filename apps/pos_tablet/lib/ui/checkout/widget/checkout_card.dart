import 'package:flutter/material.dart';

/// Card style shared with the cart panel: flat, surface colour, 20dp radius,
/// outlineVariant border, 20dp inner padding. (Theme-level styling is a later
/// refactor; until then this keeps the look in one place.)
class CheckoutCard extends StatelessWidget {
  const CheckoutCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}
