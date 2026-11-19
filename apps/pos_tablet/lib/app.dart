import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/data/sync/sync_coordinator.dart';
import 'package:pos_tablet/di/app_dependencies.dart';
import 'package:pos_tablet/ui/bootstrap/bootstrap_view_model.dart';
import 'package:pos_tablet/ui/sales/viewmodel/cart_view_model.dart';
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
          create: (ctx) => SalesHistoryViewModel(
            dependencies.saleRepository,
            ctx.read<ShiftViewModel>(),
          ),
        ),
        ChangeNotifierProvider<CartViewModel>(create: (_) => CartViewModel()),
        ChangeNotifierProvider<BootstrapViewModel>(
          create: (_) => BootstrapViewModel(dependencies.bootstrapRepository),
        ),

        ChangeNotifierProvider<ShiftSummaryViewModel>(
          create: (ctx) => ShiftSummaryViewModel(
            dependencies.shiftSummaryRepository,
            ctx.read<ShiftViewModel>(),
          ),
        ),

        ChangeNotifierProvider<SyncCoordinatorImp>(
          create: (ctx) => SyncCoordinatorImp(
            shiftSyncService: dependencies.shiftSyncService,
            connectivityService: dependencies.connectivityService,
            salesSyncService: dependencies.saleSyncService,
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
  late final BootstrapViewModel _bootstrapViewModel;
  late final GoRouter _router;
  late final SyncCoordinator _syncCoordinator;
  bool _syncInitialized = false;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    _shift = context.read<ShiftViewModel>();
    _bootstrapViewModel = context.read<BootstrapViewModel>();
    _syncCoordinator = context.read<SyncCoordinatorImp>();

    _router = createRouter(_auth, _bootstrapViewModel, _shift);

    _auth.addListener(_onAuthChanged);

    _bootstrapViewModel.addListener(_onBootstrapChanged);
    _shift.addListener(_onShiftChanged);
    _onAuthChanged(); // auth might already be resolved by the time we get here
  }

  void _onBootstrapChanged() {
    if (_bootstrapViewModel.isReady && _shift.state == ShiftState.unknown) {
      _shift.restoreShift();
    }
  }

  Future<void> _onShiftChanged() async {
    if (_syncInitialized) {
      return;
    }

    final state = _shift.state;

    if (state == ShiftState.open ||
        state == ShiftState.none ||
        state == ShiftState.unknown) {
      _syncInitialized = true;

      await _syncCoordinator.initialize();
    }
  }

  // async
  void _onAuthChanged() {
    switch (_auth.status) {
      case AuthStatus.authenticated:
        _bootstrapViewModel.restoreState();
      case AuthStatus.unauthenticated:
        _shift.reset();
      case AuthStatus.uninitialized:
        break;
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _bootstrapViewModel.removeListener(_onBootstrapChanged);
    _router.dispose();
    _shift.removeListener(_onShiftChanged);
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
