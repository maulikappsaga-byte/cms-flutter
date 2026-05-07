import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
  }) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = const Color(0xFFE8F5E9);
        icon = Icons.check_circle_rounded;
        iconColor = Colors.green[700]!;
        break;
      case SnackBarType.error:
        backgroundColor = const Color(0xFFFFEBEE);
        icon = Icons.error_rounded;
        iconColor = Colors.red[700]!;
        break;
      case SnackBarType.warning:
        backgroundColor = const Color(0xFFFFF3E0);
        icon = Icons.warning_rounded;
        iconColor = Colors.orange[800]!;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = const Color(0xFFE3F2FD);
        icon = Icons.info_rounded;
        iconColor = const Color(0xFF00478D);
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
