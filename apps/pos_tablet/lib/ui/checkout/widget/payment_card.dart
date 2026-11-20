import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/checkout/checkout_view_model.dart';
import 'package:pos_tablet/ui/checkout/widget/checkout_card.dart';
import 'package:pos_tablet/ui/checkout/widget/payment_method.dart';
import 'package:pos_tablet/ui/checkout/widget/payment_method_selector.dart';
import 'package:pos_tablet/ui/checkout/widget/quick_cash_chip.dart';
import 'package:pos_tablet/ui/checkout/widget/tender_math.dart';

import 'package:pos_tablet/ui/sale/viewmodel/cart_view_model.dart';

import 'package:pos_tablet/ui/shared/money.dart';
import 'package:provider/provider.dart';

/// Payment method, amount received, change due and the Complete Sale button.
///
/// Rebuilds when the cart changes, the amount is typed, or the sale command
/// starts/finishes; the rest of the screen is untouched by those.
///
/// [shrinkWrap] = true (portrait): the card is only as tall as its content.
/// false (landscape): the card fills its parent and the button is pinned to
/// the bottom. Either way the fields scroll and the button never moves.
class PaymentCard extends StatefulWidget {
  const PaymentCard({
    super.key,
    required this.viewModel,
    required this.controller,
    required this.method,
    required this.onMethodChanged,
    required this.onCompleteSale,
    required this.shrinkWrap,
  });

  final CheckoutViewModel viewModel;
  final TextEditingController controller;
  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final VoidCallback onCompleteSale;
  final bool shrinkWrap;

  @override
  State<PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  // Created once so ListenableBuilder doesn't resubscribe on every build.
  // (viewModel and controller are owned by the screen and never change.)
  late final Listenable _listenable = Listenable.merge([
    widget.controller,
    widget.viewModel.completeSale,
  ]);

  void _setReceivedCents(int cents) {
    final text = (cents / 100).toStringAsFixed(2);
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cart, _) => ListenableBuilder(
        listenable: _listenable,
        builder: (context, _) => _buildCard(context, cart),
      ),
    );
  }

  Widget _buildCard(BuildContext context, CartViewModel cart) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isProcessing = widget.viewModel.completeSale.running;
    final isCash = widget.method == PaymentMethod.cash;
    final totalCents = cart.totalCents;
    final receivedCents = parseCents(widget.controller.text);

    final canComplete = canCompleteSale(
      hasItems: cart.items.isNotEmpty,
      method: widget.method,
      receivedCents: receivedCents,
      totalCents: totalCents,
    );

    final fields = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentMethodSelector(
            selected: widget.method,
            onChanged: isProcessing ? null : widget.onMethodChanged,
          ),

          if (isCash) ...[
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              enabled: !isProcessing,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              // Same field styling as the catalogue search field.
              decoration: InputDecoration(
                labelText: 'Amount received (USD)',
                prefixText: '\$ ',
                filled: true,
                fillColor: colors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
              // No setState: this card listens to the controller directly.
            ),
            if (totalCents > 0) ...[
              const SizedBox(height: 12),
              QuickCashChips(
                totalCents: totalCents,
                receivedCents: receivedCents,
                enabled: !isProcessing,
                onSelected: _setReceivedCents,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Change due', style: theme.textTheme.bodyMedium),
                ),
                Text(
                  formatUsd(
                    changeCents(
                      receivedCents: receivedCents,
                      totalCents: totalCents,
                    ),
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              'Confirm the customer\'s EcoCash payment of '
              '${formatUsd(totalCents)} has been received before completing the sale.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );

    return CheckoutCard(
      child: Column(
        mainAxisSize: widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Scrollable fields; the button below stays pinned.
          if (widget.shrinkWrap)
            Flexible(child: fields)
          else
            Expanded(child: fields),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (canComplete && !isProcessing)
                  ? widget.onCompleteSale
                  : null,
              icon: isProcessing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(isProcessing ? 'Processing...' : 'Complete Sale'),
            ),
          ),
        ],
      ),
    );
  }
}
