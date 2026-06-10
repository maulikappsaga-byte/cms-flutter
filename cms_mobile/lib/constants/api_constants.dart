import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }
  
  // static String apiKey =
  //     'a467c9ae749554658c974ac9bdcdef787b9cc9ece425d33e2784e36c1aa37fc1';
  static String apiKey =
      'QOOizWQhXaQpEAk2Vu0C6N2MC4LObntMtU8NGNYwVkubR0UA80ZmndwL3BECYl4q';

  // Pusher Configuration
  static const String pusherAppKey = 'bacd6dd427751c42eecc';
  static const String pusherCluster = 'ap2';

  static String? resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // For absolute URLs returned from localhost APIs
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (url.contains('127.0.0.1') || url.contains('localhost')) {
        return url.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
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
