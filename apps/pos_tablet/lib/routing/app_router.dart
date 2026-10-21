import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/auth/login_screen.dart';
import 'package:pos_tablet/ui/cash/cash_movements_screen.dart';
import 'package:pos_tablet/ui/dashboard/dashboard_screen.dart';
import 'package:pos_tablet/ui/sales/cart_item.dart';
import 'package:pos_tablet/ui/sales/cart_screen.dart';
import 'package:pos_tablet/ui/sales/checkout_screen.dart';
import 'package:pos_tablet/ui/sales/product_catalogue_screen.dart';
import 'package:pos_tablet/ui/sales/receipt_screen.dart';
import 'package:pos_tablet/ui/sales/sales_history_screen.dart';
import 'package:pos_tablet/ui/shifts/shift_screen.dart';
import 'package:pos_tablet/ui/shifts/start_shift_screen.dart';
import 'package:pos_tablet/ui/stock/stock_receiving_screen.dart';
import 'package:shared_core/ui/auth_view_model.dart';

// ...your other imports unchanged

const _publicRoutes = {'/login'};
const _homeRoute = '/start-shift'; // where to land after login

GoRouter createRouter(AuthViewModel auth) => GoRouter(
  initialLocation: '/login',
  refreshListenable: auth,
  redirect: (context, state) {
    // Still restoring session: stay put, don't redirect yet
    if (auth.status == AuthStatus.uninitialized) return null;

    final loggedIn = auth.status == AuthStatus.authenticated;
    final onPublic = _publicRoutes.contains(state.matchedLocation);

    if (!loggedIn && !onPublic) return '/login';
    if (loggedIn && onPublic) return _homeRoute;
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/shift',
      name: 'shift',
      builder: (context, state) => const ShiftScreen(),
    ),
    GoRoute(
      path: '/start-shift',
      name: 'startShift',
      builder: (context, state) => const StartShiftScreen(),
    ),
    GoRoute(
      path: '/cash-movements',
      name: 'cashMovements',
      builder: (context, state) => const CashMovementsScreen(),
    ),
    GoRoute(
      path: '/stock-receiving',
      name: 'stockReceiving',
      builder: (context, state) => const StockReceivingScreen(),
    ),
    GoRoute(
      name: 'sales-history',
      path: '/sales-history',
      builder: (context, state) {
        return SalesHistoryScreen();
      },
    ),
    GoRoute(
      name: 'receipt',
      path: '/receipt',
      builder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;

        return ReceiptScreen(
          saleId: extra['saleId'] as String,
          items: List<CartItem>.from(extra['items'] as List),
          paymentMethod: extra['paymentMethod'] as String,
          total: (extra['total'] as num).toDouble(),
          amountReceived: (extra['amountReceived'] as num).toDouble(),
          change: (extra['change'] as num).toDouble(),
        );
      },
    ),
    GoRoute(
      path: '/sales',
      name: 'sales',
      builder: (context, state) => const ProductCatalogueScreen(),
    ),
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) =>
          CheckoutScreen(items: state.extra as List<CartItem>? ?? []),
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => CartScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => DashboardScreen(),
    ),
  ],
);
