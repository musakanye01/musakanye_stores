import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/di/app_dependencies.dart';
import 'package:pos_tablet/ui/sales/viewmodel/catalogue_view_model.dart';
import 'package:pos_tablet/ui/sales/viewmodel/checkout_view_model.dart';
import 'package:pos_tablet/ui/sales/viewmodel/sales_history_view_model.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:pos_tablet/ui/stock/stock_receiving_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/ui/auth_view_model.dart';

import 'routing/app_router.dart';

class PosTabletApp extends StatelessWidget {
  final AppDependencies dependencies;
  const PosTabletApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: dependencies),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(dependencies.authRepository),
        ),
        ChangeNotifierProvider<ShiftViewModel>(
          create: (_) => ShiftViewModel(dependencies.shiftRepository),
        ),
        ChangeNotifierProvider<CatalogueViewModel>(
          create: (_) => CatalogueViewModel(dependencies.productRepository),
        ),

        ChangeNotifierProvider<CheckoutViewModel>(
          create: (_) => CheckoutViewModel(dependencies.saleRepository),
        ),

        ChangeNotifierProvider<StockReceivingViewModel>(
          create: (_) =>
              StockReceivingViewModel(dependencies.stockReceivingRepository),
        ),

        ChangeNotifierProvider<SalesHistoryViewModel>(
          create: (_) =>
              SalesHistoryViewModel(dependencies.saleRepository)..loadInitial(),
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
      title: 'POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457C5)),
      ),
      routerConfig: _router,
    );
  }
}
