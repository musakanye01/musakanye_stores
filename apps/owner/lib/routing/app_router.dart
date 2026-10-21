// ...your other imports unchanged

import 'package:go_router/go_router.dart';
import 'package:owner/ui/auth/login_screen.dart';
import 'package:owner/ui/dashboard/owner_dashboard_screen.dart';
import 'package:shared_core/ui/auth_view_model.dart';

const _publicRoutes = {'/login'};
const _homeRoute = '/'; // where to land after login

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
      path: '/',
      name: 'ownerDashboard',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
