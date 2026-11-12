import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/routing/app_router.dart';
import 'package:pos_tablet/ui/bootstrap/bootstrap_view_model.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:shared_core/ui/auth_view_model.dart';

void main() {
  String? redirect({
    required AuthStatus auth,
    required BootstrapStatus bootstrap,
    required ShiftState shift,
    required String location,
  }) {
    return resolveRedirect(
      auth: auth,
      bootstrap: bootstrap,
      shift: shift,
      location: location,
    );
  }

  group('auth not resolved', () {
    test('uninitialized never redirects', () {
      expect(
        redirect(
          auth: AuthStatus.uninitialized,
          bootstrap: BootstrapStatus.unknown,
          shift: ShiftState.unknown,
          location: loginRoute,
        ),
        isNull,
      );

      expect(
        redirect(
          auth: AuthStatus.uninitialized,
          bootstrap: BootstrapStatus.unknown,
          shift: ShiftState.unknown,
          location: dashboardRoute,
        ),
        isNull,
      );
    });
  });

  group('unauthenticated', () {
    test('protected routes redirect to login', () {
      expect(
        redirect(
          auth: AuthStatus.unauthenticated,
          bootstrap: BootstrapStatus.required,
          shift: ShiftState.none,
          location: dashboardRoute,
        ),
        loginRoute,
      );

      expect(
        redirect(
          auth: AuthStatus.unauthenticated,
          bootstrap: BootstrapStatus.required,
          shift: ShiftState.none,
          location: startShiftRoute,
        ),
        loginRoute,
      );
    });

    test('login route remains accessible', () {
      expect(
        redirect(
          auth: AuthStatus.unauthenticated,
          bootstrap: BootstrapStatus.required,
          shift: ShiftState.none,
          location: loginRoute,
        ),
        isNull,
      );
    });
  });

  group('bootstrap checking', () {
    test('does not redirect while bootstrap restores', () {
      for (final route in [dashboardRoute, '/sales', '/checkout', '/shift']) {
        expect(
          redirect(
            auth: AuthStatus.authenticated,
            bootstrap: BootstrapStatus.checking,
            shift: ShiftState.none,
            location: route,
          ),
          isNull,
          reason: route,
        );
      }
    });

    test('does not redirect while bootstrap unknown', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.unknown,
          shift: ShiftState.none,
          location: dashboardRoute,
        ),
        isNull,
      );
    });
  });

  group('authenticated but bootstrap required', () {
    test('all routes redirect to bootstrap', () {
      for (final route in [
        dashboardRoute,
        '/sales',
        '/checkout',
        '/cart',
        '/shift',
        '/sales-history',
        '/cash-movements',
      ]) {
        expect(
          redirect(
            auth: AuthStatus.authenticated,
            bootstrap: BootstrapStatus.required,
            shift: ShiftState.none,
            location: route,
          ),
          bootstrapRoute,
          reason: route,
        );
      }
    });

    test('bootstrap route remains accessible', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.required,
          shift: ShiftState.none,
          location: bootstrapRoute,
        ),
        isNull,
      );
    });
  });

  group('bootstrapped but shift restoring', () {
    test('does not redirect while local shift restores', () {
      for (final route in [dashboardRoute, '/sales', '/checkout']) {
        expect(
          redirect(
            auth: AuthStatus.authenticated,
            bootstrap: BootstrapStatus.ready,
            shift: ShiftState.unknown,
            location: route,
          ),
          isNull,
          reason: route,
        );
      }
    });
  });

  group('bootstrapped with no shift', () {
    test('login redirects to start shift', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.ready,
          shift: ShiftState.none,
          location: loginRoute,
        ),
        startShiftRoute,
      );
    });

    test('dashboard redirects to start shift', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.ready,
          shift: ShiftState.none,
          location: dashboardRoute,
        ),
        startShiftRoute,
      );
    });

    test('start shift remains accessible', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.ready,
          shift: ShiftState.none,
          location: startShiftRoute,
        ),
        isNull,
      );
    });

    test('bootstrap route redirects to start shift', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.ready,
          shift: ShiftState.none,
          location: bootstrapRoute,
        ),
        startShiftRoute,
      );
    });
  });

  group('bootstrapped with open shift', () {
    test('login redirects to dashboard', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.ready,
          shift: ShiftState.open,
          location: loginRoute,
        ),
        dashboardRoute,
      );
    });

    test('start shift redirects to dashboard', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.ready,
          shift: ShiftState.open,
          location: startShiftRoute,
        ),
        dashboardRoute,
      );
    });

    test('bootstrap route redirects to dashboard', () {
      expect(
        redirect(
          auth: AuthStatus.authenticated,
          bootstrap: BootstrapStatus.ready,
          shift: ShiftState.open,
          location: bootstrapRoute,
        ),
        dashboardRoute,
      );
    });

    test('protected routes remain accessible', () {
      for (final route in [
        dashboardRoute,
        '/shift',
        '/sales',
        '/sales-history',
        '/cart',
        '/checkout',
        '/receipt/abc',
        '/cash-movements',
        '/stock-receiving',
      ]) {
        expect(
          redirect(
            auth: AuthStatus.authenticated,
            bootstrap: BootstrapStatus.ready,
            shift: ShiftState.open,
            location: route,
          ),
          isNull,
          reason: route,
        );
      }
    });
  });
}
