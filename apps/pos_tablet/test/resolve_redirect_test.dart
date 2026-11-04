import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/routing/app_router.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:shared_core/ui/auth_view_model.dart';

void main() {
  String? redirect(AuthStatus auth, ShiftState shift, String location) =>
      resolveRedirect(auth: auth, shift: shift, location: location);

  group('auth not resolved', () {
    test('uninitialized never redirects', () {
      expect(
        redirect(AuthStatus.uninitialized, ShiftState.unknown, '/login'),
        isNull,
      );
      expect(
        redirect(AuthStatus.uninitialized, ShiftState.unknown, dashboardRoute),
        isNull,
      );
    });
  });

  group('unauthenticated', () {
    test('protected route goes to login', () {
      expect(
        redirect(AuthStatus.unauthenticated, ShiftState.none, dashboardRoute),
        loginRoute,
      );
      expect(
        redirect(AuthStatus.unauthenticated, ShiftState.none, startShiftRoute),
        loginRoute,
      );
    });

    test('login stays on login', () {
      expect(
        redirect(AuthStatus.unauthenticated, ShiftState.none, loginRoute),
        isNull,
      );
    });
  });

  group('authenticated, shift state still loading', () {
    test('stays put on any route', () {
      for (final route in [loginRoute, startShiftRoute, dashboardRoute]) {
        expect(
          redirect(AuthStatus.authenticated, ShiftState.unknown, route),
          isNull,
          reason: route,
        );
      }
    });
  });

  group('authenticated with an open shift', () {
    test('login goes to dashboard', () {
      expect(
        redirect(AuthStatus.authenticated, ShiftState.open, loginRoute),
        dashboardRoute,
      );
    });

    test('start-shift goes to dashboard', () {
      expect(
        redirect(AuthStatus.authenticated, ShiftState.open, startShiftRoute),
        dashboardRoute,
      );
    });

    test('dashboard and its sub-routes stay', () {
      expect(
        redirect(AuthStatus.authenticated, ShiftState.open, dashboardRoute),
        isNull,
      );
      expect(
        redirect(
          AuthStatus.authenticated,
          ShiftState.open,
          '$dashboardRoute/anything',
        ),
        isNull,
      );
    });
  });

  group('authenticated without a shift', () {
    test('login goes to start-shift', () {
      expect(
        redirect(AuthStatus.authenticated, ShiftState.none, loginRoute),
        startShiftRoute,
      );
    });

    test('dashboard and sub-routes go to start-shift', () {
      expect(
        redirect(AuthStatus.authenticated, ShiftState.none, dashboardRoute),
        startShiftRoute,
      );
      expect(
        redirect(
          AuthStatus.authenticated,
          ShiftState.none,
          '$dashboardRoute/anything',
        ),
        startShiftRoute,
      );
    });

    test('start-shift stays', () {
      expect(
        redirect(AuthStatus.authenticated, ShiftState.none, startShiftRoute),
        isNull,
      );
    });
  });
}
