import 'dart:convert';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../services/pusher_service.dart';
import '../services/queue_detail_api.dart';
import '../widgets/custom_snackbar.dart';
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
  bool _isLoading = true;
  bool _isActionLoading = false;
  
  String _currentNextPatient = '--';
  final String _waitTime = '00:00';
  int _completedCount = 0;
  int _pendingCount = 0;
  int _totalAppointments = 0;
  
  final int _doctorId = 2; // Default doctor for this receptionist
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
      final response = await _queueApi.getQueueDetails(doctorId: _doctorId);
      
      if (response != null && response['data'] != null) {
        final queueData = response['data']['queue'];
        final currentPatient = queueData['current_patient'];
        
        setState(() {
          if (currentPatient != null) {
            final name = currentPatient['patient_name'] ?? 'Unknown';
            final token = currentPatient['token_number'] ?? currentPatient['token'] ?? '--';
            _currentNextPatient = '$token $name';
          } else {
            _currentNextPatient = 'No Patient';
          }
          
          // These might need different endpoints, but we'll use placeholder logic for now
          // or extract from queueData if available.
          _totalAppointments = queueData['total_tokens'] ?? 0;
          _completedCount = queueData['completed_tokens'] ?? 0;
          _pendingCount = _totalAppointments - _completedCount;
          
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
      final response = await _queueApi.callNextPatient(doctorId: _doctorId);
      
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
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(color: AppColors.primary, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Live Queue Manager',
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOW SERVING',
                                  style: textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentNextPatient,
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('WAIT TIME', style: textTheme.labelLarge),
                                const SizedBox(height: 4),
                                Text(
                                  _waitTime,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isActionLoading ? null : _callNextPatient,
                          child: _isActionLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('CALL NEXT PATIENT'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: 0.75,
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
                  Navigator.pushNamed(context, '/book-appointment');
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
              _buildAppointmentItem(
                context,
                '09:00 AM',
                'Eleanor Penhaligon',
                'Check-up',
                'Token #104',
                textTheme,
              ),
              const SizedBox(height: 12),
              _buildAppointmentItem(
                context,
                '10:30 AM',
                'Arthur Sterling',
                'Follow-up',
                'Token #102',
                textTheme,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
