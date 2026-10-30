import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:pos_tablet/data/source/sale_service.dart';
import 'package:shared_core/data/local/dao/sales_dao.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleSyncService with WidgetsBindingObserver {
  final SalesDao _salesDao;
  final SaleService _saleService;
  final SupabaseClient _supabase;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<AuthState>? _authSubscription;

  bool _isSyncing = false;
  bool _started = false;

  SaleSyncService({
    required this._salesDao,
    required SaleService saleService,
    required SupabaseClient supabaseClient,
    Connectivity? connectivity,
  }) : _saleService = saleService,
       _supabase = supabaseClient,
       _connectivity = connectivity ?? Connectivity();

  /// Starts automatic sync triggers.
  void start() {
    if (_started) return;

    _started = true;
    WidgetsBinding.instance.addObserver(this);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(syncPendingSales());
      }
    });

    _authSubscription = _supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        unawaited(syncPendingSales());
      }
    });

    // Attempt pending sales when the app starts.
    unawaited(syncPendingSales());
  }

  /// Retry pending sales whenever the app returns to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(syncPendingSales());
    }
  }

  /// Synchronizes all locally stored sales that haven't reached Supabase.
  Future<void> syncPendingSales() async {
    if (_isSyncing) return;

    // Do not attempt RPC calls without an authenticated session.
    if (_supabase.auth.currentSession == null) return;

    try {
      final connectivity = await _connectivity.checkConnectivity();

      if (connectivity.every((result) => result == ConnectivityResult.none)) {
        return;
      }

      _isSyncing = true;

      final pendingSales = await _salesDao.getUnsynced();

      for (final sale in pendingSales) {
        try {
          final localLines = await _salesDao.getLinesForSale(sale.id);

          if (localLines.isEmpty) {
            throw StateError('Sale ${sale.id} has no locally stored items.');
          }

          final items = localLines.map((line) {
            return {
              'variant_id': line.variantId,
              'quantity': line.quantity,
              'unit_price_cents': line.unitPriceCents,
            };
          }).toList();

          final isCash = sale.paymentMethod == 'cash';

          if (!isCash && sale.paymentMethod != 'ecocash_usd') {
            throw StateError(
              'Unsupported payment method: ${sale.paymentMethod}',
            );
          }

          final result = await _saleService.syncOfflineSale(
            saleId: sale.id,
            idempotencyKey: sale.idempotencyKey,
            shiftId: sale.shiftId,
            paymentMethod: sale.paymentMethod,
            createdAt: sale.createdAt,
            totalCents: sale.totalCents,
            tenderedCents: isCash ? sale.tenderedCents : null,
            items: items,
          );

          switch (result) {
            case Ok<SaleResult>(value: final syncedSale):
              if (syncedSale.saleId != sale.id ||
                  syncedSale.totalCents != sale.totalCents) {
                throw StateError(
                  'The server response does not match local sale ${sale.id}.',
                );
              }

              await _salesDao.markSynced(sale.id);

            case Error<SaleResult>(error: final error):
              throw error;
          }
        } catch (e) {
          await _salesDao.markSyncFailed(
            sale.id,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    } catch (e) {
      debugPrint('Sale synchronization failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Stops listeners when the service is no longer needed.
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);

    await _connectivitySubscription?.cancel();
    await _authSubscription?.cancel();

    _started = false;
  }
}
