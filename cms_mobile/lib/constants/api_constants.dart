import 'package:flutter/foundation.dart';

class ApiConstants {
  // static String get baseUrl {
  //   if (defaultTargetPlatform == TargetPlatform.android) {
  //     return 'http://10.0.2.2:8001/api';
  //   }
  //   return 'http://localhost:8001/api';
  // }

  // static String apiKey =
  //     'c7a6ba883d24c2f63e257245e36fe4bcbfebfe33ab8ca578f9ea8e8361056fee';

  static String get baseUrl => 'https://healthcare.appsaga.io/api';
  static String apiKey =
      '20c99fa5c4eb513ccf119cb72080b9e9f8d75c718e9d41feda3bead447d5c043';

  // Pusher Configuration
  static const String pusherAppKey = 'bacd6dd427751c42eecc';
  static const String pusherCluster = 'ap2';

  static String? resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // For absolute URLs returned from localhost APIs
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (url.contains('127.0.0.1') || url.contains('localhost')) {
        return url
            .replaceAll('127.0.0.1', '10.0.2.2')
            .replaceAll('localhost', '10.0.2.2');
      }
    }

    // For relative URLs
    if (!url.startsWith('http')) {
      final baseDomain = baseUrl.replaceAll('/api', '');
      return '$baseDomain/storage/$url';
    }

    return url;
  }
}
