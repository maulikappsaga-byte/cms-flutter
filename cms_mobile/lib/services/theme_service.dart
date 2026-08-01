import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'clinic_detail_api.dart';
import 'subscription_service.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  static ThemeService get instance => _instance;

  final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(AppTheme.createTheme(null));

  static const String _themeCacheKey = 'clinic_theme_palette';

  Timer? _pollingTimer;

  Future<void> init() async {
    // Try to load cached theme
    final prefs = await SharedPreferences.getInstance();
    final cachedPaletteString = prefs.getString(_themeCacheKey);
    if (cachedPaletteString != null) {
      try {
        final Map<String, dynamic> cachedPalette = json.decode(cachedPaletteString);
        themeNotifier.value = AppTheme.createTheme(cachedPalette);
      } catch (e) {
        // Fallback to default on parse error
        themeNotifier.value = AppTheme.createTheme(null);
      }
    } else {
      themeNotifier.value = AppTheme.createTheme(null);
    }
    
    // Start background polling for real-time theme updates
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchAndApplyTheme();
    });
  }

  Future<void> fetchAndApplyTheme() async {
    try {
      final details = await ClinicDetailApi().getClinicDetails();
      
      // Update subscription expiration status
      SubscriptionService.instance.checkSubscriptionFromClinicData(details);

      Map<String, dynamic>? palette;
      
      // Look for palette in the response
      if (details.containsKey('data') && details['data'] != null && details['data'] is Map) {
        final data = details['data'] as Map<String, dynamic>;
        if (data.containsKey('clinic') && data['clinic'] != null && data['clinic'] is Map) {
          final clinic = data['clinic'] as Map<String, dynamic>;
          if (clinic.containsKey('color_palette') && clinic['color_palette'] != null && clinic['color_palette'] is Map) {
            palette = clinic['color_palette'] as Map<String, dynamic>;
          }
        }
      } else if (details.containsKey('color_palette') && details['color_palette'] != null && details['color_palette'] is Map) {
        palette = details['color_palette'] as Map<String, dynamic>;
      }

      final prefs = await SharedPreferences.getInstance();
      if (palette != null) {
        // Cache it
        await prefs.setString(_themeCacheKey, json.encode(palette));
      } else {
        // Clear cache if palette is explicitly null/removed from backend
        await prefs.remove(_themeCacheKey);
      }

      // Apply it (AppTheme.createTheme safely falls back to defaults if palette is null)
      themeNotifier.value = AppTheme.createTheme(palette);
    } catch (e) {
      // API failed or no palette found, ignore or log
      debugPrint('Error fetching theme palette: $e');
    }
  }
}
