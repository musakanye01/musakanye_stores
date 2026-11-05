import 'package:flutter/material.dart';
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
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:pos_tablet/ui/shifts/start_shift_screen.dart';
import 'package:pos_tablet/ui/stock/stock_receiving_screen.dart';
import 'package:shared_core/ui/auth_view_model.dart';

const loginRoute = '/login';
const startShiftRoute = '/start-shift';
const dashboardRoute = '/dashboard'; // use your real paths
const _publicRoutes = {loginRoute};

String? resolveRedirect({
  required AuthStatus auth,
  required ShiftState shift,
  required String location,
}) {
  if (auth == AuthStatus.uninitialized) return null;

  final onPublic = _publicRoutes.contains(location);

  if (auth == AuthStatus.unauthenticated) {
    return onPublic ? null : loginRoute;
  }

  // Authenticated, local shift check still running: stay put.
  if (shift == ShiftState.unknown) return null;

  final home = shift == ShiftState.open ? dashboardRoute : startShiftRoute;
  if (onPublic) return home;

  if (shift == ShiftState.open && location == startShiftRoute) {
    return dashboardRoute;
  }
  if (shift == ShiftState.none && location.startsWith(dashboardRoute)) {
    return startShiftRoute;
  }
  return null;
}

GoRouter createRouter(AuthViewModel auth, ShiftViewModel shift) => GoRouter(
  initialLocation: loginRoute,
  refreshListenable: Listenable.merge([auth, shift]),
  redirect: (context, state) => resolveRedirect(
    auth: auth.status,
    shift: shift.state,
    location: state.matchedLocation,
  ),
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
      builder: (context, state) => CheckoutScreen(),
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
