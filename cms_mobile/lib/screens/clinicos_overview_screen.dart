import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import '../theme.dart';
import '../services/doctor_detail_api.dart';
import '../services/patient_api.dart';
import '../services/user_session.dart';
import '../widgets/custom_snackbar.dart';

class ClinicosOverviewScreen extends StatefulWidget {
  final String? patientName;
  final String? patientPhone;

  const ClinicosOverviewScreen({
    super.key,
    this.patientName,
    this.patientPhone,
  });

  @override
  State<ClinicosOverviewScreen> createState() => _ClinicosOverviewScreenState();
}

class _ClinicosOverviewScreenState extends State<ClinicosOverviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;
  bool _isRefreshing = false;
  
  // Dynamic data
  String _nowServing = '07';
  late String _yourToken;
  String _waitTime = '~45 mins';
  late String _patientNameDisplay;

  final _doctorApi = DoctorDetailApi();
  final _patientApi = PatientApi();

  @override
  void initState() {
    super.initState();
    _yourToken = UserSession.lastToken ?? '--';
    _patientNameDisplay = UserSession.lastBookedName ?? 'Guest';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Only fetch if we have a valid 10-digit phone
    final phone = widget.patientPhone ?? UserSession.lastBookedPhone;
    if (phone != null && phone.length == 10) {
      _fetchOverviewData();
    }
  }

  Future<void> _fetchOverviewData() async {
    final name = widget.patientName ?? UserSession.lastBookedName ?? "Guest";
    final phone = widget.patientPhone ?? UserSession.lastBookedPhone;

    if (phone == null || phone.length != 10) {
      log("Skipping fetch: Invalid phone number '$phone'");
      return;
    }

    if (mounted) setState(() => _isLoading = true);
    try {
      // 1. Fetch general doctor/queue details
      final doctorResponse = await _doctorApi.getDoctorDetails(
        doctorId: 2,
        name: name,
        phone: phone,
        date: "2026-05-07",
      );

      // 2. Fetch specific patient token status (New API)
      final tokenResponse = await _patientApi.checkToken(phone: phone);

      log("Doctor API Response: $doctorResponse");
      log("Token API Response: $tokenResponse");

      if (mounted) {
        setState(() {
          // 1. Update queue info from doctor API
          if (doctorResponse != null && doctorResponse['data'] != null) {
            final data = doctorResponse['data'];
            _nowServing = data['now_serving']?.toString() ?? _nowServing;
            _waitTime = data['estimated_wait']?.toString() ?? _waitTime;
          }

          // 2. Update user specific info from token API (Robust Parsing)
          if (tokenResponse != null) {
            dynamic data = tokenResponse['data'] ?? tokenResponse;
            
            // If data contains an 'appointment' object (common pattern)
            if (data is Map && data['appointment'] != null) {
              data = data['appointment'];
            }

            if (data is Map) {
              // Try to find token in common field names
              final newToken = data['token']?.toString() ?? 
                              data['token_number']?.toString() ?? 
                              data['appointment_token']?.toString();
              
              if (newToken != null) {
                _yourToken = newToken;
                // Also update UserSession so it persists during this session
                UserSession.lastToken = newToken;
              }

              final newName = data['name']?.toString() ?? data['patient_name']?.toString();
              if (newName != null) {
                _patientNameDisplay = newName;
                UserSession.lastBookedName = newName;
              }
            }
          }
        });
      }
    } catch (e) {
      log("Error fetching overview data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    await _fetchOverviewData();
    
    if (mounted) {
      setState(() => _isRefreshing = false);
      CustomSnackBar.show(
        context: context,
        message: 'Status updated',
        type: SnackBarType.success,
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E3FF).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Color(0xFF00478D),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ClinicOS',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00478D),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: (_isLoading || _isRefreshing) ? null : _refresh,
            icon: (_isLoading || _isRefreshing)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00478D),
                    ),
                  )
                : const Icon(Icons.refresh, color: Color(0xFF00478D)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF00478D),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Queue Indicator
                _buildQueueIndicator(),
                const SizedBox(height: 32),
                
                // Patient Status Card
                _buildStatusCard(),
                const SizedBox(height: 12),
                
                Text(
                  'Estimated wait time: $_waitTime',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00478D),
                  ),
                ),
                const SizedBox(height: 48),

                // Action Grid
                _buildActionGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR STATUS (${_patientNameDisplay.toUpperCase()})',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Token Number',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD6E3FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _yourToken,
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              backgroundColor: const Color(0xFFEDEEEF),
              progressColor: AppColors.primary,
              progress: 0.75,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NOW SERVING',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _nowServing,
              style: GoogleFonts.manrope(
                fontSize: 100,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appointment No.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        // Live Badge
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionCard(
          icon: Icons.add_circle,
          label: 'Book\nAppointment',
          color: AppColors.primary,
          iconColor: Colors.white,
          textColor: Colors.white,
          hasBgIcon: true,
          onTap: () {
            Navigator.pushNamed(context, '/book-appointment');
          },
        ),
        _buildActionCard(
          icon: Icons.medical_information,
          label: 'Your\nDoctor',
          color: Colors.white,
          iconColor: AppColors.primary,
          textColor: AppColors.onSurface,
          hasBgIcon: false,
          onTap: () {
            Navigator.pushNamed(context, '/doctor-details');
          },
        ),
        _buildActionCard(
          icon: Icons.business,
          label: 'Clinic\nDetails',
          color: Colors.white,
          iconColor: AppColors.primary,
          textColor: AppColors.onSurface,
          hasBgIcon: false,
          onTap: () {
            Navigator.pushNamed(context, '/clinic-details');
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required Color textColor,
    required bool hasBgIcon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: color == Colors.white
                ? Border.all(color: const Color(0xFFF1F5F9))
                : null,
            boxShadow: [
              if (color != Colors.white)
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasBgIcon
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFF005EB8).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final Color backgroundColor;
  final Color progressColor;
  final double progress;

  _CircularProgressPainter({
    required this.backgroundColor,
    required this.progressColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 5;

    canvas.drawCircle(center, radius, backgroundPaint);

    final double sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
