import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sale/viewmodel/cart_view_model.dart';
import 'package:pos_tablet/ui/sale/viewmodel/catalogue_view_model.dart';
import 'package:pos_tablet/ui/sale/widget/cart/cart_content.dart';
import 'package:pos_tablet/ui/sale/widget/cart/cart_panel.dart';
import 'package:pos_tablet/ui/sale/widget/cart/cart_summary_bar.dart';
import 'package:pos_tablet/ui/sale/widget/catalogue_body.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

import '../shared/tablet_scaffold.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key, this.showCartOnOpen = false});

  final bool showCartOnOpen;

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  // Layout constants.
  static const double _cartPanelWidth = 380;
  static const Duration _cartPanelDuration = Duration(milliseconds: 250);

  // Providers are resolved once; the screen itself never rebuilds because of
  // them. Rebuilds are scoped to the small widgets below using context.select.
  late final CatalogueViewModel _catalogue;
  late final CartViewModel _cart;
  late final TextEditingController _searchController;

  /// Landscape-only inline cart panel.
  bool _cartPanelOpen = false;

  bool _initialCartHandled = false;

  /// Context of the portrait cart bottom sheet while it is open.
  BuildContext? _sheetContext;

  @override
  void initState() {
    super.initState();
    _catalogue = context.read<CatalogueViewModel>();
    _cart = context.read<CartViewModel>();
    _searchController = TextEditingController(text: _catalogue.searchQuery);

    // FIX: the panel used to stay open after the cart was emptied, leaving
    // no way to close it (the summary bar hides its button when the cart is
    // empty). Close it automatically whenever the cart becomes empty.
    _cart.addListener(_onCartChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialCartHandled || !widget.showCartOnOpen) return;

    _initialCartHandled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _cart.isEmpty) return;
      _openCart();
    });
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    _searchController.dispose();
    super.dispose();
  }

  bool get _isLandscape =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  void _onCartChanged() {
    if (!mounted || !_cart.isEmpty) return;

    // Landscape: close the inline panel.
    if (_cartPanelOpen) {
      setState(() => _cartPanelOpen = false);
    }

    // Portrait: dismiss the bottom sheet (Clear, or removing the last line).
    final sheetContext = _sheetContext;
    if (sheetContext != null && sheetContext.mounted) {
      _sheetContext = null;
      Navigator.of(sheetContext).pop();
    }
  }

  void _addToCart(CatalogueItem item) {
    final added = _cart.add(item);

    // Also fires when an out-of-stock card is tapped, so the user gets
    // feedback instead of a silent no-op.
    if (!added && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No more stock available for this item.'),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  void _openCart() {
    if (_cart.isEmpty) return;

    if (_isLandscape) {
      setState(() => _cartPanelOpen = true);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        // Keep the sheet's own context so _onCartChanged can pop exactly
        // this route (and not whatever happens to be on top).
        _sheetContext = sheetContext;
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: CartContent(onClose: () => Navigator.of(sheetContext).pop()),
        );
      },
    ).whenComplete(() => _sheetContext = null);
  }

  void _closeCartPanel() {
    setState(() => _cartPanelOpen = false);
  }

  /// Single handler for the summary bar (button and tap): toggles the inline
  /// panel in landscape, opens the bottom sheet in portrait.
  void _toggleCart() {
    if (_isLandscape && _cartPanelOpen) {
      _closeCartPanel();
    } else {
      _openCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLandscape = _isLandscape;

    // FIX: no longer hides the panel when the keyboard opens. The old
    // behaviour made the cart vanish and the grid jump to full width every
    // time the search field was focused.
    final showCartPanel = isLandscape && _cartPanelOpen;

    return TabletScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Sale',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // Search remains above the entire catalogue area.
              TextField(
                controller: _searchController,
                onChanged: _catalogue.setSearchQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products by name, SKU or category',
                  prefixIcon: const Icon(Icons.search),
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
              ),
              const SizedBox(height: 16),

              // FIX: one row, one catalogue. The grid used to be built twice
              // (once directly, once beside the cart panel), each taking half
              // the width, and a stray divider/spacers sat on the wrong side.
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: CatalogueBody(onAdd: _addToCart)),
                    SizedBox(width: 16),
                    CartPanel(
                      open: showCartPanel,
                      width: _cartPanelWidth,
                      duration: _cartPanelDuration,
                      onClose: _closeCartPanel,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              CartSummaryBar(
                isLandscape: isLandscape,
                panelOpen: showCartPanel,
                onPressed: _toggleCart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
