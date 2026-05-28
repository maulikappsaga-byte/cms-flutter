import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }
  
  static String apiKey =
      'QOOizWQhXaQpEAk2Vu0C6N2MC4LObntMtU8NGNYwVkubR0UA80ZmndwL3BECYl4q';

  // Pusher Configuration
  static const String pusherAppKey = 'bacd6dd427751c42eecc';
  static const String pusherCluster = 'ap2';
}
