import 'package:flutter/material.dart';
import 'package:pos_tablet/data/repository/product_repo.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:pos_tablet/data/repository/shift_repo.dart';
import 'package:pos_tablet/data/repository/stock_repo.dart';
import 'package:pos_tablet/data/source/product_service.dart';
import 'package:pos_tablet/data/source/sale_service.dart';
import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:pos_tablet/data/source/stock_receiving_service.dart';
import 'package:shared_core/data/auth_repo.dart';
import 'package:shared_core/data/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDependencies {
  late final AuthService _authService;
  late final AuthRepository _authRepository;
  late final ShiftService _shiftService;
  late final ShiftRepository _shiftRepository;
  late final ProductRepository _productRepository;
  late final ProductService _productService;
  late final SaleService _saleService;
  late final SaleRepository _saleRepository;
  late final StockReceivingService _stockReceivingService;
  late final StockReceivingRepository _stockReceivingRepository;

  late final Supabase _supabase;

  AppDependencies._();

  static Future<AppDependencies> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    final dependencies = AppDependencies._();
    await dependencies._initializeDependencies();
    return dependencies;
  }

  Future<void> _initializeDependencies() async {
    _supabase = await Supabase.initialize(
      url: "https://xzbdtxfkjsvwzhnxahum.supabase.co",
      publishableKey: "sb_publishable_fJa1_rB7pwyQfkzv3wm87g_GO7h35vj",
    );
    // Core Database & Local Feature Services
    _authService = AuthService(_supabase.client);
    _authRepository = AuthRepositoryImpl(authService: _authService);
    _shiftService = ShiftService(_supabase.client);
    _shiftRepository = ShiftRepositoryImpl(_shiftService);
    _productService = ProductService(_supabase.client);
    _productRepository = ProductRepositoryImpl(_productService);
    _saleService = SaleService(_supabase.client);
    _saleRepository = SaleRepositoryImpl(_saleService);
    _stockReceivingService = StockReceivingService(_supabase.client);
    _stockReceivingRepository = StockReceivingRepositoryImpl(
      _stockReceivingService,
    );
  }

  // Getters
  AuthRepository get authRepository => _authRepository;
  ShiftRepository get shiftRepository => _shiftRepository;
  ProductRepository get productRepository => _productRepository;
  SaleRepository get saleRepository => _saleRepository;
  StockReceivingRepository get stockReceivingRepository =>
      _stockReceivingRepository;
}
