import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cms_mobile/services/subscription_service.dart';
import 'package:cms_mobile/widgets/subscription_expired_dialog.dart';

void main() {
  group('SubscriptionService Unit Tests', () {
    late SubscriptionService service;

    setUp(() {
      service = SubscriptionService.instance;
      service.isExpiredNotifier.value = false;
    });

    test('Active subscription with future date sets isExpired to false', () {
      final data = {
        'data': {
          'clinic': {
            'subscription_start_date': '2024-01-01',
            'subscription_end_date': '2099-12-31',
          }
        }
      };

      service.checkSubscriptionFromClinicData(data, now: DateTime(2026, 8, 1));
      expect(service.isExpired, isFalse);
    });

    test('Expired subscription with past date sets isExpired to true', () {
      final data = {
        'data': {
          'clinic': {
            'subscription_start_date': '2020-01-01',
            'subscription_end_date': '2023-12-31',
          }
        }
      };

      service.checkSubscriptionFromClinicData(data, now: DateTime(2026, 8, 1));
      expect(service.isExpired, isTrue);
    });

    test('Date-only subscription_end_date remains valid on the same day through 23:59:59', () {
      final data = {
        'clinic': {
          'subscription_end_date': '2026-08-01',
        }
      };

      // Current time is midday on August 1st, 2026
      service.checkSubscriptionFromClinicData(data, now: DateTime(2026, 8, 1, 12, 0, 0));
      expect(service.isExpired, isFalse);

      // Current time is 1 millisecond past midnight on August 2nd, 2026 -> EXPIRED
      service.checkSubscriptionFromClinicData(data, now: DateTime(2026, 8, 2, 0, 0, 0, 1));
      expect(service.isExpired, isTrue);
    });

    test('Flat data payload structure parsing works correctly', () {
      final data = {
        'subscription_start_date': '2020-01-01',
        'subscription_end_date': '2021-01-01',
      };

      service.checkSubscriptionFromClinicData(data, now: DateTime(2026, 8, 1));
      expect(service.isExpired, isTrue);
    });

    test('Null or missing subscription_end_date defaults isExpired to false', () {
      final data = {
        'data': {
          'clinic': {
            'name': 'Sample Clinic',
          }
        }
      };

      service.checkSubscriptionFromClinicData(data, now: DateTime(2026, 8, 1));
      expect(service.isExpired, isFalse);
    });
  });

  group('SubscriptionExpiredOverlay Widget Tests', () {
    testWidgets('Renders exact required text message when overlay is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SubscriptionExpiredOverlay(),
          ),
        ),
      );

      // Verify header title
      expect(find.text('Clinic Access Unavailable'), findsOneWidget);

      // Verify exact required text message
      expect(
        find.text('App is currently unavailable. Please contact the clinic directly.'),
        findsOneWidget,
      );

      // Verify status badge
      expect(find.text('SUBSCRIPTION EXPIRED'), findsOneWidget);
    });
  });
}
