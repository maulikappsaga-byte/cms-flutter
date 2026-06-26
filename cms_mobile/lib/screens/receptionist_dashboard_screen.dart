
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
    extends State<ReceptionistDashboardScreen>
    with WidgetsBindingObserver {
  final QueueApi _queueApi = QueueApi();
  final AppointmentApi _appointmentApi = AppointmentApi();
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _doctorQueues = [];
  List<Map<String, dynamic>> _todaySchedules = [];
  int? _actionLoadingDoctorId;
  int? _actionTransferLoadingDoctorId;
  int? _actionToggleHoldDoctorId;
  int _completedCount = 0;
  int _pendingCount = 0;
  int _totalAppointments = 0;
  List<dynamic> _todayAppointments = [];
  
  final DoctorDetailApi _doctorApi = DoctorDetailApi();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!UserSession.isLoggedIn || UserSession.userRole != 'receptionist') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackBar.show(
          context: context,
          message: 'Access denied. Receptionist login required.',
          type: SnackBarType.error,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      });
      return;
    }
    _fetchDashboardData();
    _setupPusher();
  }

  void _setupPusher() {
    PusherService().addListener(_onPusherEvent);
    _subscribeToPusher();
  }

  void _subscribeToPusher() {
    PusherService().subscribeToQueue();
  }

  void _unsubscribeFromPusher() {
    PusherService().unsubscribeFromQueue();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PusherService().removeListener(_onPusherEvent);
    _unsubscribeFromPusher();
    super.dispose();
  }

  /// Re-connect Pusher and refresh data when the app returns to foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('Dashboard: App resumed — reconnecting Pusher and refreshing data.');
      PusherService().reconnect().then((_) {
        _subscribeToPusher();
      });
      _fetchDashboardData(silent: true);
    }
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.eventName.startsWith('pusher:')) return;
    debugPrint('Dashboard: Pusher event received: ${event.eventName} — refreshing data.');
    // Always call _fetchDashboardData() directly.
    // Previously this only called _refreshIndicatorKey.currentState?.show(),
    // but RefreshIndicator is conditionally rendered behind the _isLoading
    // guard, so its state is null whenever _isLoading == true, silently
    // swallowing every Pusher event that arrives during a load cycle.
    _fetchDashboardData(silent: true);
  }

  Future<void> _fetchDashboardData({bool silent = false}) async {
    if (mounted && !silent) {
      setState(() => _isLoading = true);
    }
    
    try {
      final doctorResponse = await _doctorApi.getDoctors();
      List<dynamic> doctors = [];
      if (doctorResponse != null && doctorResponse['status'] == true) {
        doctors = doctorResponse['data']?['doctors'] ?? [];
      }

      final appointmentsResponse = await _appointmentApi.getTodayAppointments();
      List<Map<String, dynamic>> fetchedQueues = [];
      List<Map<String, dynamic>> fetchedSchedules = [];

      for (var doc in doctors) {
        final docId = int.tryParse(doc['id'].toString());
        if (docId == null) continue;

        String docNameStr = doc['name']?.toString() ?? 'Demo Doctor';
        if (!docNameStr.toLowerCase().startsWith('dr')) {
          docNameStr = 'Dr. $docNameStr';
        }
        final docName = docNameStr;

        final queueResponse = await _queueApi.getQueueDetails(doctorId: docId);
        
        String currentToken = '--';
        String currentName = 'No Patient';
        String nextToken = 'None';
        String nextName = '';
        List<Map<String, String>> nextPatients = [];

        try {
          final scheduleResponse = await _doctorApi.getTodaySchedule(doctorId: docId);
          if (scheduleResponse != null && scheduleResponse['data'] != null && scheduleResponse['data']['schedules'] != null) {
            final schedules = scheduleResponse['data']['schedules'] as List;
            for (var schedule in schedules) {
               final start = schedule['start_time'] ?? '';
               final end = schedule['end_time'] ?? '';
               fetchedSchedules.add({
                 'doctor_name': schedule['doctor_name'] ?? docName,
                 'schedule_time': start.isNotEmpty && end.isNotEmpty ? '$start - $end' : 'N/A',
                 'schedule_status': schedule['status']?.toString().toUpperCase() ?? 'ACTIVE',
               });
            }
          }
        } catch (e) {
          debugPrint('Dashboard: Error fetching schedule for doctor $docId: $e');
        }

        if (queueResponse != null && queueResponse['data'] != null) {
          final queueData = queueResponse['data']['queue'];
          final currentPatient = queueData['current_patient'];
          final waitingList = queueData['waiting_list'];

          if (currentPatient != null) {
            currentName = currentPatient['appointment']?['patient_name'] ?? currentPatient['patient_name'] ?? 'Unknown';
            currentToken = currentPatient['token_number']?.toString() ?? '--';
          }

          if (waitingList != null && waitingList is List && waitingList.isNotEmpty) {
            final nextPatient = waitingList[0];
            nextToken = nextPatient['token_number']?.toString() ?? 'None';
            nextName = nextPatient['appointment']?['patient_name'] ?? nextPatient['patient_name'] ?? '';

            for (var i = 0; i < waitingList.length && i < 3; i++) {
              final patient = waitingList[i];
              nextPatients.add({
                'token': patient['token_number']?.toString() ?? 'None',
                'name': patient['appointment']?['patient_name'] ?? patient['patient_name'] ?? '',
              });
            }
          }
        }

        fetchedQueues.add({
          'doctor_id': docId,
          'doctor_name': docName,
          'is_on_hold': doc['is_on_hold'] == 1 || doc['is_on_hold'] == true,
          'current_token': currentToken,
          'current_name': currentName,
          'next_token': nextToken,
          'next_name': nextName,
          'next_patients': nextPatients,
        });
      }

      if (mounted) {
        setState(() {
          _doctorQueues = fetchedQueues;
          _todaySchedules = fetchedSchedules;

          if (appointmentsResponse != null && appointmentsResponse['status'] == true) {
            _todayAppointments = appointmentsResponse['data']?['todays appointments'] ?? [];
            _totalAppointments = _todayAppointments.length;
            _completedCount = _todayAppointments.where((app) => app['status']?.toString().toLowerCase() == 'completed').length;
            _pendingCount = _totalAppointments - _completedCount;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      if (!silent && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _callNextPatient(int doctorId) async {
    setState(() => _actionLoadingDoctorId = doctorId);
    
    try {
      final response = await _queueApi.callNextPatient(doctorId: doctorId);
      
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
      if (mounted) {
        setState(() => _actionLoadingDoctorId = null);
      }
    }
  }

  Future<void> _toggleHoldStatus(int doctorId) async {
    setState(() => _actionToggleHoldDoctorId = doctorId);
    
    try {
      final response = await _queueApi.toggleHold(doctorId: doctorId);
      
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
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: "Failed to toggle hold status.",
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _actionToggleHoldDoctorId = null);
      }
    }
  }

  Future<void> _transferPatient(int doctorId) async {
    setState(() => _actionTransferLoadingDoctorId = doctorId);
    
    try {
      final response = await _queueApi.transferPatient(doctorId: doctorId);
      
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
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: "Failed to transfer patient.",
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _actionTransferLoadingDoctorId = null);
      }
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
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
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
            SizedBox(width: 12),
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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                try {
                  await AuthApi.logout();
                } catch (e) {
                  debugPrint('Logout API failed: $e');
                }
                await UserSession.clearLoginSession();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/clinicos-overview', (route) => false);
              }
            },
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
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
          SizedBox(width: 8),
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
          ? Center(child: CircularProgressIndicator())
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
              if (_doctorQueues.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No active queues')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _doctorQueues.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final queue = _doctorQueues[index];
                    final bool isActionLoading = _actionLoadingDoctorId == queue['doctor_id'];
                    final bool isTransferLoading = _actionTransferLoadingDoctorId == queue['doctor_id'];
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: queue['is_on_hold'] == true ? Colors.orange.withValues(alpha: 0.3) : Theme.of(context).extension<AppCustomColors>()!.accentBlue, width: 1.5),
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
                              decoration: BoxDecoration(
                                color: Theme.of(context).extension<AppCustomColors>()!.inputBackground, // Light blue top header
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: queue['is_on_hold'] == true ? Colors.orange : Theme.of(context).colorScheme.error, // Red or orange dot
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      queue['doctor_name'],
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _actionToggleHoldDoctorId == queue['doctor_id'] ? null : () => _toggleHoldStatus(queue['doctor_id']),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: queue['is_on_hold'] == true ? Colors.orange.withValues(alpha: 0.1) : Colors.transparent,
                                        border: Border.all(color: queue['is_on_hold'] == true ? Colors.orange.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: _actionToggleHoldDoctorId == queue['doctor_id']
                                          ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: queue['is_on_hold'] == true ? Colors.orange : Colors.grey))
                                          : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(queue['is_on_hold'] == true ? Icons.pause_circle_outline : Icons.pause_circle_outline, color: queue['is_on_hold'] == true ? Colors.orange : Colors.grey, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            'ON HOLD',
                                            style: TextStyle(
                                              color: queue['is_on_hold'] == true ? Colors.orange : Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outlineVariant),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Text(
                                    'NOW SERVING',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    queue['current_token'],
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: queue['is_on_hold'] == true ? Colors.orange : Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    queue['current_name'],
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (queue['is_on_hold'] == true) ...[
                                    SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.05),
                                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.orange, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            'SESSION PAUSED',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: queue['is_on_hold'] == true ? 16 : 24),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Text(
                                        'NEXT:',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      if (queue['next_patients'] == null || (queue['next_patients'] as List).isEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.surface,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'None',
                                            style: textTheme.labelMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      else
                                        ...((queue['next_patients'] as List).map<Widget>((patient) {
                                          final token = patient['token'] ?? 'None';
                                          final name = patient['name'] ?? '';
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.surface,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  token,
                                                  style: textTheme.labelMedium?.copyWith(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (name.isNotEmpty) ...[
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '- $name',
                                                    style: textTheme.labelMedium?.copyWith(
                                                      color: Theme.of(context).colorScheme.primary,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          );
                                        })),
                                    ],
                                  ),
                                  SizedBox(height: 32),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isActionLoading || queue['is_on_hold'] == true ? null : () => _callNextPatient(queue['doctor_id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.secondary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: isActionLoading 
                                              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                              : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.campaign_outlined, size: 20),
                                              SizedBox(width: 4),
                                              Text('Call Next'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: isTransferLoading || queue['is_on_hold'] == true ? null : () => _transferPatient(queue['doctor_id']),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Theme.of(context).colorScheme.primary,
                                            side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: isTransferLoading
                                              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
                                              : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.change_circle_outlined, size: 22),
                                                  Text('+6', style: TextStyle(fontSize: 10, height: 1.2)),
                                                ],
                                              ),
                                              SizedBox(width: 4),
                                              Text('Transfer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
                      );
                    },
                  ),
              SizedBox(height: 32),
              // Today's Schedule
              _buildTodayScheduleCard(context, textTheme),
              SizedBox(height: 32),
              // Today's Performance
              Text(
                'TODAY\'S PERFORMANCE',
                style: textTheme.labelLarge?.copyWith(letterSpacing: 2),
              ),
              SizedBox(height: 12),
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
                  SizedBox(width: 12),
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
              SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                            color: Theme.of(context).colorScheme.onSurface,
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
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              // Administrative Tools
              Text(
                'ADMINISTRATIVE TOOLS',
                style: textTheme.labelLarge?.copyWith(letterSpacing: 2),
              ),
              SizedBox(height: 12),
              _buildActionButton(
                context,
                Icons.add_box,
                'Book New Appointment',
                textTheme,
                onTap: () {
                  Navigator.pushNamed(context, '/receptionist-book-appointment');
                },
              ),

              SizedBox(height: 32),
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
                        color: Theme.of(context).colorScheme.primary,
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No appointments today')),
                ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.outline,
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
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                sub,
                style: textTheme.labelLarge?.copyWith(
                  color: sub.startsWith('+')
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
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
          color: Theme.of(context).extension<AppCustomColors>()!.inputBackground,
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
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
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
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
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
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 12, color: Theme.of(context).colorScheme.outline),
                      SizedBox(width: 4),
                      Text(phone, style: textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
                    ],
                  ),
                ],
                if (status != null) ...[
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 12, color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 4),
                      Text(status.toUpperCase(), style: textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Text(
            token,
            style: textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleCard(BuildContext context, TextTheme textTheme) {
    if (_todaySchedules.isEmpty) return SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).extension<AppCustomColors>()!.accentBlue, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Today\'s Schedule',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).extension<AppCustomColors>()!.accentBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'AVAILABILITY',
                  style: textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ..._todaySchedules.map((schedule) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        schedule['doctor_name'] ?? 'Doctor',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                        SizedBox(width: 8),
                        Text(
                          schedule['schedule_time'] ?? '09:00 AM - 05:00 PM',
                          style: textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: (schedule['schedule_status'] ?? 'ACTIVE') == 'ACTIVE' ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          schedule['schedule_status'] ?? 'ACTIVE',
                          style: textTheme.labelSmall?.copyWith(
                            color: (schedule['schedule_status'] ?? 'ACTIVE') == 'ACTIVE' ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

