import '../theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../services/user_session.dart';
import '../widgets/custom_snackbar.dart';
import '../services/queue_detail_api.dart';
import '../services/pusher_service.dart';
import '../services/doctor_detail_api.dart';
import '../services/clinic_detail_api.dart';


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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;
  bool _isRefreshing = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Dynamic data — sourced from /queue/live API
  String _nowServing = '--';
  String _yourToken = '--';
  String _patientNameDisplay = 'Guest';
  String _clinicName = UserSession.clinicName ?? 'ClinicOS';

  final _queueApi = QueueApi();
  final _doctorApi = DoctorDetailApi();
  final _clinicApi = ClinicDetailApi();
  int? _doctorId;

  @override
  void initState() {
    super.initState();

    // Register for app lifecycle events (foreground/background transitions).
    WidgetsBinding.instance.addObserver(this);

    // Load saved session values
    final today = DateTime.now().toString().split(' ')[0];
    if (UserSession.lastBookingDate == today) {
      _yourToken = UserSession.lastToken ?? '--';
      _patientNameDisplay = UserSession.lastBookedName ?? 'Guest';
    } else {
      _yourToken = '--';
      _patientNameDisplay = 'Guest';
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fetch live queue on load — this also resolves the doctor ID and
    // subscribes to the doctor-specific queue channel dynamically.
    _fetchOverviewData();

    // Subscribe to the          log("Pusher: Fetching clinic details to get clinic ID...");
    PusherService().addListener(_onPusherEvent);
    _subscribeToPusher();
  }

  Future<void> _subscribeToPusher() async {
    await PusherService().subscribeToQueue();
  }

  void _unsubscribeFromPusher() {
    PusherService().unsubscribeFromQueue();
  }

  /// Re-connect Pusher and refresh data when the app returns to foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log("ClinicosOverview: App resumed — reconnecting Pusher and refreshing data.");
      // Reconnect the Pusher socket in case it was dropped in the background.
      PusherService().reconnect().then((_) {
        _subscribeToPusher();
      });
      _fetchOverviewData();
    }
  }

  /// Handles incoming Pusher events and updates _nowServing in real time.
  void _onPusherEvent(PusherEvent event) { 
    log("ClinicosOverview: Pusher Event -> ${event.eventName} : ${event.data}");

    if (event.eventName.startsWith('pusher:')) return;

    // Refresh live queue data on any queue-updates event
    log("ClinicosOverview: Refreshing data on Pusher event...");
    _fetchOverviewData(silent: true);
  }

  /// Fetches the current serving token from /queue/live.
  /// This is the single source of truth for "Now Serving".
  Future<void> _fetchOverviewData({bool silent = false}) async {
    log("ClinicosOverview: Fetching live queue data...");
    if (mounted && !silent) setState(() => _isLoading = true);

    try {
      try {
        final clinicResponse = await _clinicApi.getClinicDetails();
        final name = clinicResponse['data']?['clinic']?['name']?.toString();
        if (name != null && name.trim().isNotEmpty) {
          final trimmed = name.trim();
          _clinicName = trimmed;
          UserSession.saveClinicName(trimmed);
        }
      } catch (e) {
        log("ClinicosOverview: Error fetching clinic details: $e");
      }

      if (_doctorId == null) {
        final doctorResponse = await _doctorApi.getDoctors();
        if (doctorResponse != null && doctorResponse['status'] == true) {
          final doctors = doctorResponse['data']?['doctors'];
          if (doctors is List && doctors.isNotEmpty) {
            _doctorId = int.tryParse(doctors.first['id'].toString());
            log("Pusher: Authorizing channel \$channelName with socketId \$socketId");
          }
        }
      }

      final docId =
          _doctorId ?? 1; // Fallback to 1 if we couldn't load it from API

      String? appointmentId;
      final today = DateTime.now().toString().split(' ')[0];
      if (UserSession.lastBookingDate == today && UserSession.lastAppointmentId != null) {
        appointmentId = UserSession.lastAppointmentId;
      }

      final response = await _queueApi.getQueueDetails(
        doctorId: appointmentId == null ? docId : null,
        appointmentId: appointmentId,
      );

      if (response != null && response['data'] != null) {
        final queue = response['data']['queue'];
        if (queue != null) {
          final currentPatient = queue['current_patient'];
          if (currentPatient != null) {
            // Backend may use 'token_number' or 'token'
            final token =
                currentPatient['token_number']?.toString() ??
                currentPatient['token']?.toString();
            log("ClinicosOverview: Now serving: $token");
            log("Pusher: Authorized successfully.");
            setState(() => _nowServing = token ?? '--');
          } else {
            log("ClinicosOverview: No active patient in queue");
            if (mounted) setState(() => _nowServing = '--');
          }
        }
      }
    } catch (e) {
      log("ClinicosOverview: Error fetching queue: $e");
    } finally {
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    // Reload session in case token was updated elsewhere
    await UserSession.init();
    setState(() {
      final today = DateTime.now().toString().split(' ')[0];
      if (UserSession.lastBookingDate == today) {
        _yourToken = UserSession.lastToken ?? '--';
        _patientNameDisplay = UserSession.lastBookedName ?? 'Guest';
      } else {
        _yourToken = '--';
        _patientNameDisplay = 'Guest';
      }
    });

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
    WidgetsBinding.instance.removeObserver(this);
    PusherService().removeListener(_onPusherEvent);
    _unsubscribeFromPusher();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).extension<AppCustomColors>()!.accentBlue.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_hospital,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _clinicName,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: (_isLoading || _isRefreshing) ? null : _refresh,
            icon: (_isLoading || _isRefreshing)
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        color: Theme.of(context).colorScheme.primary,
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
                SizedBox(height: 32),

                // Patient Status Card
                _buildStatusCard(),
                SizedBox(height: 32),

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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Token Number',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<AppCustomColors>()!.accentBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _yourToken,
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueIndicator() {
    double progress = 0.0;
    try {
      final current = int.parse(_nowServing);
      // Scale progress: token / 20 (a reasonable max cycle), clamped 0-1
      progress = (current / 20).clamp(0.05, 1.0);
    } catch (_) {}

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              backgroundColor: const Color(0xFFEDEEEF),
              progressColor: Theme.of(context).colorScheme.primary,
              progress: progress,
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
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 4),
            Text(
              _nowServing,
              style: GoogleFonts.manrope(
                fontSize: 100,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
                height: 1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Appointment No.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: Theme.of(context).colorScheme.primary,
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
                SizedBox(width: 8),
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
          color: Theme.of(context).colorScheme.primary,
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
          iconColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onSurface,
          hasBgIcon: false,
          onTap: () {
            Navigator.pushNamed(context, '/doctors-list');
          },
        ),
        _buildActionCard(
          icon: Icons.business,
          label: 'Clinic\nDetails',
          color: Colors.white,
          iconColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onSurface,
          hasBgIcon: false,
          onTap: () {
            log("Pusher: Fetched clinic ID \$_clinicId");Navigator.pushNamed(context, '/clinic-details');
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
                      : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              SizedBox(height: 12),
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
