import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ClinicosOverviewScreen extends StatefulWidget {
  const ClinicosOverviewScreen({super.key});

  @override
  State<ClinicosOverviewScreen> createState() => _ClinicosOverviewScreenState();
}

class _ClinicosOverviewScreenState extends State<ClinicosOverviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    // Simulate network fetch
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clinic data updated'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD6E3FF), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA__J41_xC8zaUMSCleBUb2ogdYUlz59mfLXy6O4eT-qUnHawPEDAGglm-6AS4Mp_Kzr6qsxrJh5i_NqP0C5gx-x7P4LVlsZReRmzqHaVS-YJ7AWAWSZ7PiiUrPIc-QMNZY1TSDExh2IH9UUGshLN91Gfc8Ug7_4upctS2vsWqO6gR48K5iPtq1Vr2hMJrZvbW86MavYTfNSNZiLtSSvo-IZodH-3UQACs9AnC_vaUz7qXsHErxoZ9qz25-UYCJn63GrOi8wcvwIbc',
                  ),
                  fit: BoxFit.cover,
                ),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login, color: Color(0xFF00478D), size: 20),
              label: Text(
                'Login',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00478D),
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFD6E3FF).withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _isRefreshing ? null : _refresh,
            icon: _isRefreshing
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

                // Status Card
                _buildStatusCard(),
                const SizedBox(height: 16),

                // Wait Time
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: const [
                      TextSpan(text: 'Estimated wait time: '),
                      TextSpan(
                        text: '~45 mins',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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
              progress: 0.75, // Matching the dashoffset logic roughly
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
              '07',
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
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005EB8).withValues(alpha: 0.05),
            blurRadius: 20,
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
                'YOUR STATUS',
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
              '16',
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
            Navigator.pushNamed(context, '/book-appointment-app');
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
      ..strokeWidth = 4
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
