import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/auth/login_screen.dart';
import 'package:pos_tablet/ui/bootstrap/bootstrap_screen.dart';
import 'package:pos_tablet/ui/bootstrap/bootstrap_view_model.dart';
import 'package:pos_tablet/ui/cash/cash_movements_screen.dart';
import 'package:pos_tablet/ui/dashboard/dashboard_screen.dart';
import 'package:pos_tablet/ui/sales/cart_screen.dart';
import 'package:pos_tablet/ui/sales/checkout_screen.dart';
import 'package:pos_tablet/ui/sales/new_sale_screen.dart';
import 'package:pos_tablet/ui/sales/receipt_screen.dart';
import 'package:pos_tablet/ui/sales/sales_history_screen.dart';
import 'package:pos_tablet/ui/shifts/shift_screen.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:pos_tablet/ui/shifts/start_shift_screen.dart';
import 'package:pos_tablet/ui/stock/stock_receiving_screen.dart';
import 'package:shared_core/ui/auth_view_model.dart';

const loginRoute = '/login';
const bootstrapRoute = '/bootstrap';
const startShiftRoute = '/start-shift';
const dashboardRoute = '/dashboard';

const _publicRoutes = {loginRoute};

String? resolveRedirect({
  required AuthStatus auth,
  required BootstrapStatus bootstrap,
  required ShiftState shift,
  required String location,
}) {
  if (auth == AuthStatus.uninitialized) {
    return null;
  }

  final onPublic = _publicRoutes.contains(location);

  if (auth == AuthStatus.unauthenticated) {
    return onPublic ? null : loginRoute;
  }

  // Wait while bootstrap state is restoring.
  if (bootstrap == BootstrapStatus.unknown ||
      bootstrap == BootstrapStatus.checking) {
    return null;
  }

  // Device must be bootstrapped before anything else.
  if (bootstrap != BootstrapStatus.ready) {
    return location == bootstrapRoute ? null : bootstrapRoute;
  }

  // Bootstrapped. Now restore local shift state.
  if (shift == ShiftState.unknown) {
    return null;
  }

  final hasShift = shift == ShiftState.open;

  // Authenticated users should never go back to login.
  if (onPublic) {
    return hasShift ? dashboardRoute : startShiftRoute;
  }

  // Bootstrap screen should not be visible once ready.
  if (location == bootstrapRoute) {
    return hasShift ? dashboardRoute : startShiftRoute;
  }

  if (hasShift) {
    return location == startShiftRoute ? dashboardRoute : null;
  }

  // No open shift: start-shift is the only valid location.
  return location == startShiftRoute ? null : startShiftRoute;
}

GoRouter createRouter(
  AuthViewModel auth,
  BootstrapViewModel bootstrap,
  ShiftViewModel shift,
) => GoRouter(
  initialLocation: loginRoute,
  refreshListenable: Listenable.merge([auth, bootstrap, shift]),
  redirect: (context, state) => resolveRedirect(
    auth: auth.status,
    bootstrap: bootstrap.status,
    shift: shift.state,
    location: state.matchedLocation,
  ),
  routes: [
    GoRoute(
      path: loginRoute,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: bootstrapRoute,
      name: 'bootstrap',
      builder: (context, state) => const BootstrapScreen(),
    ),

    GoRoute(
      path: '/shift',
      name: 'shift',
      builder: (context, state) => const ShiftScreen(),
    ),

    GoRoute(
      path: startShiftRoute,
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
      path: '/sales-history',
      name: 'sales-history',
      builder: (context, state) => SalesHistoryScreen(),
    ),

    GoRoute(
      path: '/receipt/:saleId',
      name: 'receipt',
      builder: (context, state) {
        final saleId = state.pathParameters['saleId']!;

        return ReceiptScreen(key: ValueKey(saleId), saleId: saleId);
      },
    ),

    GoRoute(
      path: '/sales',
      name: 'sales',
      builder: (context, state) => NewSaleScreen(
        showCartOnOpen: state.uri.queryParameters['showCart'] == 'true',
      ),
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
      path: dashboardRoute,
      name: 'dashboard',
      builder: (context, state) => DashboardScreen(),
    ),
  ],
);
