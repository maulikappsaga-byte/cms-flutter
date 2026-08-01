import 'package:flutter/foundation.dart';
import 'clinic_detail_api.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();

  factory SubscriptionService() => _instance;

  SubscriptionService._internal();

  static SubscriptionService get instance => _instance;

  /// Notifier for app-wide subscription expiration state.
  final ValueNotifier<bool> isExpiredNotifier = ValueNotifier<bool>(false);

  DateTime? subscriptionStartDate;
  DateTime? subscriptionEndDate;

  bool get isExpired => isExpiredNotifier.value;

  /// Fetches clinic details from API and evaluates subscription status.
  Future<void> checkSubscription({ClinicDetailApi? api}) async {
    try {
      final apiService = api ?? ClinicDetailApi();
      final details = await apiService.getClinicDetails();
      checkSubscriptionFromClinicData(details);
    } catch (e) {
      debugPrint('Error checking subscription: $e');
    }
  }

  /// Parses clinic detail response data to determine if subscription is expired.
  void checkSubscriptionFromClinicData(Map<String, dynamic>? data, {DateTime? now}) {
    if (data == null) return;

    Map<String, dynamic>? clinicMap;

    if (data.containsKey('data') && data['data'] is Map) {
      final innerData = data['data'] as Map<String, dynamic>;
      if (innerData.containsKey('clinic') && innerData['clinic'] is Map) {
        clinicMap = innerData['clinic'] as Map<String, dynamic>;
      } else {
        clinicMap = innerData;
      }
    } else if (data.containsKey('clinic') && data['clinic'] is Map) {
      clinicMap = data['clinic'] as Map<String, dynamic>;
    } else {
      clinicMap = data;
    }

    final rawStartDate = clinicMap['subscription_start_date'];
    final rawEndDate = clinicMap['subscription_end_date'];

    subscriptionStartDate = _parseDate(rawStartDate, isEnd: false);
    subscriptionEndDate = _parseDate(rawEndDate, isEnd: true);

    final currentTime = now ?? DateTime.now();

    if (subscriptionEndDate != null) {
      final expired = currentTime.isAfter(subscriptionEndDate!);
      isExpiredNotifier.value = expired;
    } else {
      isExpiredNotifier.value = false;
    }
  }

  /// Safely parses date strings into DateTime instances.
  /// If [isEnd] is true and input is date-only (e.g. YYYY-MM-DD), sets time to 23:59:59.999.
  DateTime? _parseDate(dynamic dateVal, {required bool isEnd}) {
    if (dateVal == null) return null;
    final str = dateVal.toString().trim();
    if (str.isEmpty) return null;

    final parsed = DateTime.tryParse(str);
    if (parsed == null) return null;

    // Check if format is YYYY-MM-DD (length 10) without explicit time component
    final isDateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(str);

    if (isEnd && isDateOnly) {
      return DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59, 999);
    }

    return parsed;
  }
}
