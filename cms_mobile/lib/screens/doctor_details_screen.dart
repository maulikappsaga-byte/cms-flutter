import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/doctor_detail_api.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final int? doctorId;

  const DoctorDetailsScreen({super.key, this.doctorId});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen>
    with SingleTickerProviderStateMixin {
  final DoctorDetailApi _apiService = DoctorDetailApi();
  dynamic _doctorData;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _pulseController;
  int? _resolvedDoctorId;
  bool _isScheduleExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fetchDoctorDetails();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      if (_resolvedDoctorId == null) {
        if (widget.doctorId != null) {
          _resolvedDoctorId = widget.doctorId;
        } else {
          final doctorsResponse = await _apiService.getDoctors();
          if (doctorsResponse != null && doctorsResponse['status'] == true) {
            final doctors = doctorsResponse['data']?['doctors'];
            if (doctors is List && doctors.isNotEmpty) {
              _resolvedDoctorId = int.tryParse(doctors.first['id'].toString());
            }
          }
        }
      }

      final docId = _resolvedDoctorId ?? 1; // Fallback to 1
      final data = await _apiService.getDoctorDetails(
        doctorId: docId,
      );
      if (mounted) {
        setState(() {
          _doctorData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF005EB8)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_errorMessage'),
              TextButton(
                onPressed: _fetchDoctorDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _extractDoctorData();
    if (data == null) {
      return const Scaffold(body: Center(child: Text('Doctor not found')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF1E293B),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 22,
                  color: Color(0xFF005EB8),
                ),
                onPressed: () {
                  setState(() => _isLoading = true);
                  _fetchDoctorDetails();
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(data),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(data),
                      const SizedBox(height: 32),
                      _buildAboutSection(data),
                      const SizedBox(height: 32),
                      _buildContactSection(data),
                      const SizedBox(height: 32),
                      _buildScheduleSection(data['working_hours']),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildStickyFooter(data),
        ],
      ),
    );
  }

  dynamic _extractDoctorData() {
    try {
      if (_doctorData is Map) {
        final apiData = _doctorData['data'];
        if (apiData is Map && apiData.containsKey('doctors')) {
          final list = apiData['doctors'] as List;
          final docId = _resolvedDoctorId ?? 1;
          return list.firstWhere(
            (d) => d['id'] == docId,
            orElse: () => list.first,
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  bool _isDoctorCurrentlyAvailable(dynamic workingHours) {
    if (workingHours is! Map) return false;
    final now = DateTime.now();
    final dayNames = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    final today = dayNames[now.weekday - 1];

    final hours = workingHours[today];
    if (hours == null || hours == "Closed") return false;

    try {
      final parts = hours.split(" - ");
      if (parts.length != 2) return false;

      final start = _parseTimeString(parts[0]);
      final end = _parseTimeString(parts[1]);

      final currentTime = now.hour * 60 + now.minute;
      return currentTime >= start && currentTime <= end;
    } catch (e) {
      return false;
    }
  }

  int _parseTimeString(String time) {
    final parts = time.split(" ");
    if (parts.length < 2) return 0;
    final timeParts = parts[0].split(":");
    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);
    final bool isPM = parts[1].toUpperCase() == "PM";

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return hour * 60 + minute;
  }

  Widget _buildHeroHeader(dynamic data) {
    final bool isAvailable = _isDoctorCurrentlyAvailable(data['working_hours']);
    final Color statusColor = isAvailable
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 4),
                  image: data['profile_photo'] != null
                      ? DecorationImage(
                          image: NetworkImage(data['profile_photo']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: data['profile_photo'] == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFFCBD5E1),
                      )
                    : null,
              ),
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            data['name'] ?? 'Dr. Unknown',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(dynamic data) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatItem(
              'Experience',
              '${data['experience_years']}+ Yrs',
              Icons.military_tech_rounded,
            ),
            const SizedBox(width: 12),
            _buildStatItem(
              'Qualification',
              data['qualification'] ?? 'N/A',
              Icons.school_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF005EB8)),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection(dynamic workingHours) {
    if (workingHours is! Map) return const SizedBox.shrink();
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    // Show all 7 days when expanded, and show NOTHING when collapsed to ensure a full collapse as requested
    final List<String> daysToShow = _isScheduleExpanded ? days : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Availability',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () =>
                  setState(() => _isScheduleExpanded = !_isScheduleExpanded),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isScheduleExpanded ? 'See Less' : 'Full Week',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF005EB8),
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn, // Smoother downward expansion
          alignment: Alignment.topCenter,
          child: _isScheduleExpanded
              ? Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          ...daysToShow.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final String day = entry.value;
                            final hours = workingHours[day];
                            bool isClosed =
                                (hours == null ||
                                hours == "Closed" ||
                                (hours is List && hours.isEmpty));

                            String timeStr = 'Closed';
                            if (!isClosed) {
                              if (hours is List) {
                                timeStr = hours
                                    .map(
                                      (slot) =>
                                          "${slot['start_time']} - ${slot['end_time']}",
                                    )
                                    .join(", ");
                              } else {
                                timeStr = hours.toString();
                              }
                            }

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 18,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          day[0].toUpperCase() +
                                              day.substring(1),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isClosed
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isClosed
                                                ? const Color(0xFFFEF2F2)
                                                : const Color(0xFFF0F9FF),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            timeStr,
                                            textAlign: TextAlign.right,
                                            style: GoogleFonts.manrope(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: isClosed
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFF005EB8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index != daysToShow.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      color: const Color(0xFFF1F5F9),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAboutSection(dynamic data) {
    final about = data['about_me'] ?? data['bio'] ?? data['description'];
    if (about == null || about.toString().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Me',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F9FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF005EB8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      about.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.6,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(dynamic data) {
    final phone = data['phone_number'] ?? data['phone'] ?? data['contact_number'];
    if (phone == null || phone.toString().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F9FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Color(0xFF005EB8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone.toString(),
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStickyFooter(dynamic data) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/book-appointment-app'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005EB8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Book Appointment',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
