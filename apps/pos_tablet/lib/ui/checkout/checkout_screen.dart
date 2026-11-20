import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/sale/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/checkout/checkout_view_model.dart';
import 'package:pos_tablet/ui/checkout/widget/payment_card.dart';
import 'package:pos_tablet/ui/checkout/widget/payment_method.dart';
import 'package:pos_tablet/ui/checkout/widget/sale_summary_card.dart';
import 'package:pos_tablet/ui/checkout/widget/tender_math.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:provider/provider.dart';

import '../shared/tablet_scaffold.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _amountReceivedController = TextEditingController();
  late final CheckoutViewModel _checkoutViewModel;

  PaymentMethod _method = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _checkoutViewModel = context.read<CheckoutViewModel>();
    _checkoutViewModel.completeSale.addListener(_onSaleResult);
  }

  @override
  void dispose() {
    _checkoutViewModel.completeSale.removeListener(_onSaleResult);
    _amountReceivedController.dispose();
    super.dispose();
  }

  // ---- Actions ----
  void _backToCart() {
    context.goNamed('sales', queryParameters: {'showCart': 'true'});
  }

  void _completeSale() {
    final cart = context.read<CartViewModel>();
    final isCash = _method == PaymentMethod.cash;
    final receivedCents = parseCents(_amountReceivedController.text);

    final canComplete = canCompleteSale(
      hasItems: cart.items.isNotEmpty,
      method: _method,
      receivedCents: receivedCents,
      totalCents: cart.totalCents,
    );

    if (!canComplete) {
      _showError(
        isCash
            ? 'Enter an amount that covers the sale total.'
            : 'There are no items in this sale.',
      );
      return;
    }

    final shift = context.read<ShiftViewModel>().currentShift;
    if (shift == null) {
      _showError('No open shift. Start a shift before selling.');
      return;
    }

    _checkoutViewModel.completeSale.execute(
      CheckoutInput(
        shiftId: shift.id,
        items: cart.items,
        tenderedCents: isCash ? receivedCents! : cart.totalCents,
        paymentMethod: _method.apiValue,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _onSaleResult() {
    final command = _checkoutViewModel.completeSale;

    if (command.error) {
      final message = command.result.toString().replaceAll('Exception: ', '');
      command.clearResult();
      if (!mounted) return;
      _showError(
        message,
      ); // no catalogue reload: the stream keeps stock current
      return;
    }

    if (command.completed) {
      final sale = _checkoutViewModel.lastSale;
      command.clearResult();
      if (sale == null || !mounted) return;

      context.read<CartViewModel>().clear();
      context.goNamed('receipt', pathParameters: {'saleId': sale.saleId});
    }
  }

  @override
  Widget build(BuildContext context) {
    // The screen watches nothing but orientation; the summary and payment
    // cards listen to the cart / amount / sale command themselves.
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Read at call time; no rebuild needed for this.
        if (didPop || _checkoutViewModel.completeSale.running) return;
        _backToCart();
      },
      child: TabletScaffold(
        // Same outer structure as the sale screen: SafeArea + 20dp padding.
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ListenableBuilder(
                      listenable: _checkoutViewModel.completeSale,
                      builder: (context, _) => IconButton(
                        tooltip: 'Back to cart',
                        onPressed: _checkoutViewModel.completeSale.running
                            ? null
                            : _backToCart,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Screen title style matches "New Sale".
                    Text(
                      'Checkout',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLandscape ? _buildLandscape() : _buildPortrait(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PaymentCard _paymentCard({required bool shrinkWrap}) {
    return PaymentCard(
      viewModel: _checkoutViewModel,
      controller: _amountReceivedController,
      method: _method,
      onMethodChanged: (method) => setState(() => _method = method),
      onCompleteSale: _completeSale,
      shrinkWrap: shrinkWrap,
    );
  }

  /// Landscape: summary left, payment right.
  Widget _buildLandscape() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 3, child: SaleSummaryCard()),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: _paymentCard(shrinkWrap: false)),
      ],
    );
  }

  /// Portrait: the summary takes most of the screen, payment sits at the
  /// bottom at its natural height (capped, and scrollable inside, so the
  /// soft keyboard can't make it overflow).
  Widget _buildPortrait() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: SaleSummaryCard()),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.6,
              ),
              child: _paymentCard(shrinkWrap: true),
            ),
          ],
        );
      },
    );
  }
}
