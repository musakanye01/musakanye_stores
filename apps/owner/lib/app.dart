import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:owner/di/app_dependencies.dart';
import 'package:owner/ui/dashboard/dashboard_view_model.dart';
import 'package:owner/ui/operations/owner_operations_view_model.dart';
import 'package:owner/ui/stock/inventory_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/ui/auth_view_model.dart';

import 'routing/app_router.dart';

class OwnerApp extends StatelessWidget {
  final AppDependencies dependencies;
  const OwnerApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: dependencies),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(dependencies.authRepository),
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (_) => DashboardViewModel(dependencies.dashboardRepository),
        ),
        ChangeNotifierProvider<InventoryViewModel>(
          create: (_) => InventoryViewModel(dependencies.inventoryRepository),
        ),
        ChangeNotifierProvider<OwnerOperationsViewModel>(
          create: (_) =>
              OwnerOperationsViewModel(dependencies.operationsRepository),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthViewModel>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Owner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457C5)),
      ),
      routerConfig: _router,
    );
  }
}
