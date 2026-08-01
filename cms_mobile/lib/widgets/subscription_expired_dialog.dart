import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fullscreen overlay that blocks all user interaction when clinic subscription is expired.
class SubscriptionExpiredOverlay extends StatelessWidget {
  const SubscriptionExpiredOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          // Modal barrier to absorb all tap and drag events
          const ModalBarrier(
            dismissible: false,
            color: Color(0xDC0F172A), // Dark slate overlay backdrop
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF991B1B).withValues(alpha: 0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Warning Lock Icon Container
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFEE2E2), width: 2),
                        ),
                        child: const Icon(
                          Icons.lock_clock_rounded,
                          size: 36,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                        ),
                        child: Text(
                          'SUBSCRIPTION EXPIRED',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFDC2626),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Primary Header Title
                      Text(
                        'Clinic Access Unavailable',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Required Explicit Message
                      Text(
                        'App is currently unavailable. Please contact the clinic directly.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
