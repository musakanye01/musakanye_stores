import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sale/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/sale/widget/cart/cart_line.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:provider/provider.dart';

/// Shared cart UI used by the standalone cart route, portrait bottom sheet,
/// and landscape sliding panel.
///
/// Layout: pinned header, scrollable item list (takes all leftover space),
/// pinned footer. When the available height is short (for example the soft
/// keyboard is open next to the panel) it switches to a compact layout so
/// the fixed parts shrink instead of overflowing.
class CartContent extends StatelessWidget {
  const CartContent({super.key, this.onClose});

  final VoidCallback? onClose;

  /// Below this height the compact layout is used.
  static const double _compactHeight = 340;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CartViewModel>();
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < _compactHeight;

          return Padding(
            padding: compact
                ? const EdgeInsets.fromLTRB(16, 8, 16, 12)
                : const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pinned header.
                _buildHeader(context),
                SizedBox(height: compact ? 4 : 12),

                // Scrollable list: takes whatever height is left, so it can
                // never cause an overflow by itself.
                Expanded(
                  child: vm.isEmpty
                      ? _buildEmptyCart(context, compact)
                      : ListView.separated(
                          itemCount: vm.items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = vm.items[index];

                            return CartLine(
                              item: item,
                              onDecrease: () => vm.decrease(item.variantId),
                              onIncrease: () {
                                final increased = vm.increase(item.variantId);

                                if (!increased && context.mounted) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No more stock available for this item.',
                                        ),
                                      ),
                                    );
                                }
                              },
                              onRemove: () => vm.remove(item.variantId),
                            );
                          },
                        ),
                ),

                Divider(height: compact ? 17 : 28),

                // Pinned footer.
                compact
                    ? _buildCompactFooter(context, vm)
                    : _buildFooter(context, vm),
              ],
            ),
          );
        },
      ),
    );
  }

  /// FIX: this was an empty `Row()` and `onClose` was never used, so the
  /// cart had no way to be closed from its own UI.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Cart',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (onClose != null)
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            tooltip: 'Close cart',
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  /// Full footer: subtotal + clear on one row, full-width checkout below.
  Widget _buildFooter(BuildContext context, CartViewModel vm) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subtotal', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 3),
                  Text(
                    formatUsd(vm.totalCents),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!vm.isEmpty)
              OutlinedButton.icon(
                onPressed: vm.clear,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: vm.isEmpty ? null : () => context.goNamed('checkout'),
            icon: const Icon(Icons.payment),
            label: const Text('Proceed to Checkout'),
          ),
        ),
      ],
    );
  }

  /// Compact footer (~44dp tall instead of ~125dp): subtotal, clear and
  /// checkout all on a single row.
  Widget _buildCompactFooter(BuildContext context, CartViewModel vm) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subtotal', style: theme.textTheme.bodySmall),
              Text(
                formatUsd(vm.totalCents),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (!vm.isEmpty) ...[
          IconButton.outlined(
            onPressed: vm.clear,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear cart',
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
        ],
        FilledButton.icon(
          onPressed: vm.isEmpty ? null : () => context.goNamed('checkout'),
          icon: const Icon(Icons.payment),
          label: const Text('Checkout'),
          style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context, bool compact) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // FIX: the old empty state was a fixed-size Column (icon 64 + two texts)
    // that overflowed in a short list area. Compact mode shows just the title,
    // and scaleDown guarantees it can never overflow.
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) ...[
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: colors.outline,
              ),
              const SizedBox(height: 12),
            ],
            Text('Your cart is empty', style: theme.textTheme.titleLarge),
            if (!compact) ...[
              const SizedBox(height: 6),
              Text(
                'Add products from the catalogue to start a sale.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
