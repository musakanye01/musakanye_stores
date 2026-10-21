import 'package:flutter/material.dart';
import 'package:owner/data/repo/dashboard_repo.dart';
import 'package:owner/data/repo/inventory_repo.dart';
import 'package:owner/data/repo/owner_operations_repo.dart';
import 'package:owner/data/source/dashboard_service.dart';
import 'package:owner/data/source/inventory_service.dart';
import 'package:owner/data/source/owner_operations_service.dart';
import 'package:shared_core/data/auth_repo.dart';
import 'package:shared_core/data/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDependencies {
  late final AuthService _authService;
  late final AuthRepository _authRepository;
  late final DashboardService _dashboardService;
  late final DashboardRepository _dashboardRepository;
  late final InventoryService _inventoryService;
  late final InventoryRepository _inventoryRepository;
  late final OwnerOperationsService _operationsService;
  late final OwnerOperationsRepository _operationsRepository;

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
    _dashboardService = DashboardService(_supabase.client);
    _dashboardRepository = DashboardRepositoryImpl(
      dashboardService: _dashboardService,
    );
    _inventoryService = InventoryService(_supabase.client);
    _inventoryRepository = InventoryRepositoryImpl(_inventoryService);
    _operationsService = OwnerOperationsService(_supabase.client);
    _operationsRepository = OwnerOperationsRepositoryImpl(
      ownerOperationsService: _operationsService,
    );
  }

  // Getters
  AuthRepository get authRepository => _authRepository;
  DashboardRepository get dashboardRepository => _dashboardRepository;
  InventoryRepository get inventoryRepository => _inventoryRepository;
  OwnerOperationsRepository get operationsRepository => _operationsRepository;
}
