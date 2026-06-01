import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../services/pusher_service.dart';
import '../services/queue_detail_api.dart';
import '../widgets/custom_snackbar.dart';
import '../services/doctor_detail_api.dart';
import '../services/appointment_api.dart';
import '../services/user_session.dart';
import '../services/auth_api.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ReceptionistDashboardScreen extends StatefulWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  State<ReceptionistDashboardScreen> createState() =>
      _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState
    extends State<ReceptionistDashboardScreen> {
  final QueueApi _queueApi = QueueApi();
  final AppointmentApi _appointmentApi = AppointmentApi();
  bool _isLoading = true;
  bool _isActionLoading = false;
  
  String _doctorName = 'Dr. Demo Doctor';
  String _currentNextPatientToken = '--';
  String _currentNextPatientName = 'No Patient';
  String _nextPatientToken = 'None';
  final String _waitTime = '00:00';
  int _completedCount = 0;
  int _pendingCount = 0;
  int _totalAppointments = 0;
  List<dynamic> _todayAppointments = [];
  
  final DoctorDetailApi _doctorApi = DoctorDetailApi();
  int? _doctorId;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _setupPusher();
  }

  void _setupPusher() {
    PusherService().addListener(_onPusherEvent);
    PusherService().subscribe("clinic-updates");
  }

  @override
  void dispose() {
    PusherService().removeListener(_onPusherEvent);
    PusherService().unsubscribe("clinic-updates");
    super.dispose();
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.eventName == 'token-called' ||
        event.eventName == 'queue-updated' ||
        event.eventName == 'App\\Events\\QueueUpdated') {
      try {
        final data = jsonDecode(event.data ?? '{}');
        if (data['type'] == 'booked') {
          debugPrint('Dashboard: Booking event detected, triggering refresh indicator...');
          _refreshIndicatorKey.currentState?.show();
          return;
        }
      } catch (e) {
        debugPrint('Dashboard: Pusher data parse error: $e');
      }

      debugPrint('Dashboard: Triggering refresh indicator due to Pusher event: ${event.eventName}');
      _refreshIndicatorKey.currentState?.show();
    }
  }

  Future<void> _fetchDashboardData({bool silent = false}) async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      if (_doctorId == null) {
        final doctorResponse = await _doctorApi.getDoctors();
        if (doctorResponse != null && doctorResponse['status'] == true) {
          final doctors = doctorResponse['data']?['doctors'];
          if (doctors is List && doctors.isNotEmpty) {
            _doctorId = int.tryParse(doctors.first['id'].toString());
            _doctorName = doctors.first['name'] != null ? 'Dr. ${doctors.first['name']}' : 'Dr. Demo Doctor';
            debugPrint("ReceptionistDashboard: Dynamically loaded doctor ID: $_doctorId");
          }
        }
      }

      final docId = _doctorId ?? 1;
      final response = await _queueApi.getQueueDetails(doctorId: docId);
      final appointmentsResponse = await _appointmentApi.getTodayAppointments();
      
      if (response != null && response['data'] != null) {
        final queueData = response['data']['queue'];
        final currentPatient = queueData['current_patient'];
        
        setState(() {
          if (appointmentsResponse != null && appointmentsResponse['status'] == true) {
            _todayAppointments = appointmentsResponse['data']?['todays appointments'] ?? [];
            _totalAppointments = _todayAppointments.length;
            _completedCount = _todayAppointments.where((app) => app['status']?.toString().toLowerCase() == 'completed').length;
            _pendingCount = _totalAppointments - _completedCount;
          } else {
            _totalAppointments = queueData['total_tokens'] ?? 0;
            _completedCount = queueData['completed_tokens'] ?? 0;
            _pendingCount = _totalAppointments - _completedCount;
          }
          
          if (currentPatient != null) {
            _currentNextPatientName = currentPatient['patient_name'] ?? 'Unknown';
            _currentNextPatientToken = currentPatient['token_number']?.toString() ?? currentPatient['token']?.toString() ?? '--';
          } else {
            _currentNextPatientName = 'No Patient';
            _currentNextPatientToken = '--';
          }
          
          if (queueData['next_patients'] != null && queueData['next_patients'] is List && queueData['next_patients'].isNotEmpty) {
             _nextPatientToken = queueData['next_patients'][0]['token_number']?.toString() ?? queueData['next_patients'][0]['token']?.toString() ?? 'None';
          } else {
             _nextPatientToken = 'None';
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      if (!silent) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _callNextPatient() async {
    setState(() => _isActionLoading = true);
    
    try {
      final docId = _doctorId ?? 1;
      final response = await _queueApi.callNextPatient(doctorId: docId);
      
      if (response != null && response['message'] != null) {
        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: response['message'],
          type: SnackBarType.success,
        );
      }
      
      // Refresh data
      await _fetchDashboardData(silent: true);
    } catch (e) {
      String errorMessage = e.toString().contains('already being served') 
          ? "A patient is currently being served."
          : "Failed to call next patient.";
          
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: errorMessage,
        type: SnackBarType.error,
      );
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  width: 2,
                ),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBj34gfl1ao1p6j0aJinT66BSaqMfy7rFuycWGFzw8bKZ00oApXUIE15XhRpO-pJUPGGw1_xPe9f5bpzOhjE54umLrSOlJ8DKqfgxTiwkYbF8MOMjyGLoR_5yQRBgXb3AZjxOonDW5yDEGKLyWOW2m_ZdTzS-Y2KVgsTsiCSP6xc_qaWwFyusYC8qXfZBA3lgd0a6HzY0YUyDUoc1vPvNI3dVBD3OlEH2pwFwzQ59wX-inhQTtc9JQCwnI6-pfubJ9KGSAWmR66E6E',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Reception Desk',
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : () => _fetchDashboardData(),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh, color: AppColors.primary),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                try {
                  await AuthApi.logout();
                } catch (e) {
                  debugPrint('Logout API failed: $e');
                }
                await UserSession.clear();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/clinicos-overview', (route) => false);
              }
            },
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black.withValues(alpha: 0.05),
            height: 1,
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => _fetchDashboardData(silent: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Queue Manager
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD1E4FA), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F8FC), // Light blue top header
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B), // Red dot
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _doctorName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF192A3E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            'NOW SERVING',
                            style: textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF9EA6B5),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentNextPatientToken,
                            style: textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF00788A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentNextPatientName,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF192A3E),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'NEXT:',
                                style: textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF9EA6B5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F5FA),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _nextPatientToken,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: const Color(0xFF00478D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isActionLoading ? null : _callNextPatient,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00788A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isActionLoading 
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.campaign_outlined, size: 20),
                                      SizedBox(width: 8),
                                      Text('Call Next'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {}, // Transfer action not defined yet
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFF4A261),
                                    side: const BorderSide(color: Color(0xFFFBE0C8), width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.change_circle_outlined, size: 22),
                                          Text('+6', style: TextStyle(fontSize: 10, height: 1.2)),
                                        ],
                                      ),
                                      SizedBox(width: 8),
                                      Text('Transfer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Today's Performance
              Text(
                'TODAY\'S PERFORMANCE',
                style: textTheme.labelLarge?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'COMPLETED',
                      _completedCount.toString().padLeft(2, '0'),
                      '+12%',
                      textTheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'PENDING',
                      _pendingCount.toString().padLeft(2, '0'),
                      'L-04',
                      textTheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
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
                        Text('TOTAL APPOINTMENTS', style: textTheme.labelLarge),
                        Text(
                          _totalAppointments.toString().padLeft(2, '0'),
                          style: textTheme.headlineLarge?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: _totalAppointments > 0 ? _completedCount / _totalAppointments : 0.0,
                        strokeWidth: 4,
                        backgroundColor: AppColors.background,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Administrative Tools
              Text(
                'ADMINISTRATIVE TOOLS',
                style: textTheme.labelLarge?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                context,
                Icons.add_box,
                'Book New Appointment',
                textTheme,
                onTap: () {
                  Navigator.pushNamed(context, '/receptionist-book-appointment');
                },
              ),

              const SizedBox(height: 32),
              // Today's Appointments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TODAY\'S APPOINTMENTS',
                    style: textTheme.labelLarge?.copyWith(letterSpacing: 2),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/appointments');
                    },
                    child: Text(
                      'View All History',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              ..._todayAppointments.map((appointment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildAppointmentItem(
                    context,
                    appointment['appointment_time'] ?? 'N/A', 
                    appointment['patient_name'] ?? 'Unknown',
                    appointment['doctor_name'] ?? 'Check-up',
                    'Token #${appointment['token_no'] ?? '--'}',
                    textTheme,
                    phone: appointment['phone']?.toString(),
                    status: appointment['status']?.toString(),
                  ),
                );
              }),
              if (_todayAppointments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No appointments today')),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 10),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 10),
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/receptionist-book-appointment');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'APPOINTMENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'BOOK APPOINTMENT'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String sub,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                sub,
                style: textTheme.labelLarge?.copyWith(
                  color: sub.startsWith('+')
                      ? AppColors.primary
                      : AppColors.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    TextTheme textTheme, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(
    BuildContext context,
    String time,
    String name,
    String service,
    String token,
    TextTheme textTheme, {
    String? phone,
    String? status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(service, style: textTheme.labelLarge),
                if (phone != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 12, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text(phone, style: textTheme.labelMedium?.copyWith(color: AppColors.outline)),
                    ],
                  ),
                ],
                if (status != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(status.toUpperCase(), style: textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            token,
            style: textTheme.labelLarge?.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
