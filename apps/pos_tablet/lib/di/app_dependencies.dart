import 'package:flutter/material.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/repository/bootsrap_repository.dart';
import 'package:pos_tablet/data/repository/product_repo.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:pos_tablet/data/repository/shift_repo.dart';
import 'package:pos_tablet/data/repository/shift_summary_repo.dart';
import 'package:pos_tablet/data/repository/stock_repo.dart';
import 'package:pos_tablet/data/source/bootstrap_service.dart';
import 'package:pos_tablet/data/source/product_service.dart';
import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:pos_tablet/data/source/stock_receiving_service.dart';
import 'package:shared_core/data/auth_repo.dart';
import 'package:shared_core/data/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import 'package:pos_tablet/data/source/sale_sync_service.dart';

class AppDependencies {
  late final AuthService _authService;
  late final AuthRepository _authRepository;
  late final ShiftService _shiftService;
  late final ShiftRepository _shiftRepository;
  late final ProductRepository _productRepository;
  late final ProductService _productService;
  late final SaleRepository _saleRepository;
  late final StockReceivingService _stockReceivingService;
  late final StockReceivingRepository _stockReceivingRepository;
  late final ShiftSummaryRepository _shiftSummaryRepository;
  late final Supabase _supabase;
  late final AppDatabase _db;
  late final BootstrapRepository _bootstrapRepository;
  late final BootstrapService _bootstrapService;

  AppDependencies._();

  static Future<AppDependencies> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    final dependencies = AppDependencies._();
    await dependencies._initializeDependencies();
    return dependencies;
  }

  Future<void> _initializeDependencies() async {
    _supabase = Supabase.instance;
    // Local Drift database — source of truth for offline-first operation.
    _db = AppDatabase();

    // Core services
    _authService = AuthService(_supabase.client);
    _authRepository = AuthRepositoryImpl(authService: _authService);
    _shiftService = ShiftService(_supabase.client);
    _shiftRepository = ShiftRepositoryImpl(_shiftService, _db.shiftsDao);
    _productService = ProductService(_supabase.client);
    _productRepository = ProductRepositoryImpl(_db.catalogueDao);
    _bootstrapService = BootstrapService(_supabase.client);
    _bootstrapRepository = BootstrapRepositoryImpl(
      _bootstrapService,
      _db.bootstrapDao,
    );

    _saleRepository = SaleRepositoryImpl(_db.salesDao, _db.shiftsDao);

    // _saleSyncService.start();

    _stockReceivingService = StockReceivingService(_supabase.client);
    _stockReceivingRepository = StockReceivingRepositoryImpl(
      _stockReceivingService,
    );
    _shiftSummaryRepository = ShiftSummaryRepositoryImpl(_db.salesDao);
  }

  // Getters
  AuthRepository get authRepository => _authRepository;
  ShiftRepository get shiftRepository => _shiftRepository;
  ProductRepository get productRepository => _productRepository;
  SaleRepository get saleRepository => _saleRepository;
  StockReceivingRepository get stockReceivingRepository =>
      _stockReceivingRepository;
  ShiftSummaryRepository get shiftSummaryRepository => _shiftSummaryRepository;
  BootstrapRepository get bootstrapRepository => _bootstrapRepository;

  /// The local Drift database. Exposed so repositories and sync service
  /// can access DAOs directly via [db.shiftsDao], [db.salesDao], etc.
  AppDatabase get db => _db;
}
