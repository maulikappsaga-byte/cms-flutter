import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/clinic_detail_api.dart';

class MedicalDisclaimerCard extends StatefulWidget {
  final String? clinicName;
  final EdgeInsetsGeometry? margin;

  const MedicalDisclaimerCard({
    super.key,
    this.clinicName,
    this.margin,
  });

  @override
  State<MedicalDisclaimerCard> createState() => _MedicalDisclaimerCardState();
}

class _MedicalDisclaimerCardState extends State<MedicalDisclaimerCard> {
  String _resolvedClinicName = 'ClinicOS';

  @override
  void initState() {
    super.initState();
    if (widget.clinicName != null && widget.clinicName!.trim().isNotEmpty) {
      _resolvedClinicName = widget.clinicName!.trim();
    } else {
      _fetchClinicName();
    }
  }

  Future<void> _fetchClinicName() async {
    try {
      final response = await ClinicDetailApi().getClinicDetails();
      final name = response['data']?['clinic']?['name']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        if (mounted) {
          setState(() {
            _resolvedClinicName = name.trim();
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final effectiveClinicName = widget.clinicName ?? _resolvedClinicName;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Soft warm amber background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFEDD5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC2410C).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFC2410C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'EMERGENCY NOTICE & MEDICAL DISCLAIMER',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: const Color(0xFFC2410C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.5,
                color: const Color(0xFF7C2D12),
              ),
              children: [
                TextSpan(
                  text: '$effectiveClinicName ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                  text:
                      'is an appointment scheduling and queue management platform. It does not provide medical diagnosis, emergency medical assistance, or clinical triage. ',
                ),
                const TextSpan(
                  text:
                      'In case of a medical emergency, please call your local emergency services immediately.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9A3412),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
