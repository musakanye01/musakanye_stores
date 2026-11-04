import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/di/app_dependencies.dart';
import 'package:pos_tablet/ui/sales/viewmodel/catalogue_view_model.dart';
import 'package:pos_tablet/ui/sales/viewmodel/checkout_view_model.dart';
import 'package:pos_tablet/ui/sales/viewmodel/sales_history_view_model.dart';
import 'package:pos_tablet/ui/shifts/shift_summary_view_model.dart';
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

        ChangeNotifierProvider<ShiftSummaryViewModel>(
          create: (_) => ShiftSummaryViewModel(
            dependencies.shiftSummaryRepository,
            context.read<ShiftViewModel>(),
          ),
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
  late final AuthViewModel _auth;
  late final ShiftViewModel _shift;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    _shift = context.read<ShiftViewModel>();
    _router = createRouter(_auth, _shift);

    _auth.addListener(_onAuthChanged);
    _onAuthChanged(); // auth might already be resolved by the time we get here
  }

  void _onAuthChanged() {
    switch (_auth.status) {
      case AuthStatus.authenticated:
        unawaited(_shift.restoreShift()); // idempotent, local-only
      case AuthStatus.unauthenticated:
        _shift.reset();
      case AuthStatus.uninitialized:
        break;
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _router.dispose();
    super.dispose();
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
