import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sale/widget/cart/cart_content.dart';

/// Inline cart panel (landscape). Slides open/closed by animating its width
/// while the content keeps its full width and is simply clipped.
///
/// FIX: the old AnimatedContainer swapped the child for SizedBox.shrink() the
/// moment the panel closed (so it vanished with no animation) and laid the
/// cart out at widths below 380 while opening (overflow errors).
class CartPanel extends StatelessWidget {
  const CartPanel({
    super.key,
    required this.open,
    required this.width,
    required this.duration,
    required this.onClose,
  });

  final bool open;
  final double width;
  final Duration duration;
  final VoidCallback onClose;

  // Gap + divider between the cart and the catalogue (12dp each side).
  static const double _dividerWidth = 24;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).colorScheme.outlineVariant;

    return TweenAnimationBuilder<double>(
      // begin is null, so the first build starts at `end` (no animation on
      // first paint); later changes animate.
      tween: Tween<double>(end: open ? 1 : 0),
      duration: duration,
      curve: Curves.easeInOut,

      // Built once and reused every animation frame.
      child: SizedBox(
        width: width + _dividerWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: width,
              child: CartContent(onClose: onClose),
            ),
            VerticalDivider(width: _dividerWidth, thickness: 1, color: divider),
          ],
        ),
      ),
      builder: (context, t, child) {
        // Fully closed: unmount the cart entirely.
        if (t == 0) return const SizedBox.shrink();

        return IgnorePointer(
          ignoring: !open, // no taps while it is sliding closed
          child: ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: t, // layout width grows/shrinks; content is clipped
              child: child,
            ),
          ),
        );
      },
    );
  }
}
