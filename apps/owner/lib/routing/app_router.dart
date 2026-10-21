import 'package:go_router/go_router.dart';
import 'package:owner/ui/dashboard/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'ownerDashboard',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
  ],
);
