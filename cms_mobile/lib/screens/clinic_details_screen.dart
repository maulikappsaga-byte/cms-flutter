import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/clinic_detail_api.dart';
import '../services/user_session.dart';
import '../widgets/hidden_staff_login_trigger.dart';
import '../constants/api_constants.dart';

class ClinicDetailsScreen extends StatefulWidget {
  final int doctorId;
  final String name;
  final String phone;
  final String date;

  const ClinicDetailsScreen({
    super.key,
    this.doctorId = 1,
    this.name = "himanshu",
    this.phone = "1234567891",
    this.date = "2026-05-01",
  });

  @override
  State<ClinicDetailsScreen> createState() => _ClinicDetailsScreenState();
}

class _ClinicDetailsScreenState extends State<ClinicDetailsScreen> {
  final ClinicDetailApi _apiService = ClinicDetailApi();
  Map<String, dynamic>? _clinicData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchClinicDetails();
  }

  Future<void> _fetchClinicDetails() async {
    try {
      final data = await _apiService.getClinicDetails(
        doctorId: widget.doctorId,
        name: widget.name,
        phone: widget.phone,
        date: widget.date,
      );

      // Dynamically extract and persist the clinic's API key if available
      final clinic = data['data']?['clinic'];
      if (clinic != null && clinic['api_key'] != null) {
        final apiKey = clinic['api_key'].toString();
        if (apiKey.isNotEmpty) {
          await UserSession.setApiKey(apiKey);
        }
      }

      setState(() {
        _clinicData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openMap(String coords) async {
    try {
      final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$coords",
      );
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _fetchClinicDetails();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Correct mapping based on API response: data -> clinic
    final clinic = _clinicData?['data']?['clinic'] ?? {};

    final clinicName = clinic['name'] ?? 'Clinic Name';
    final clinicType = clinic['description'] ?? 'General Clinic';
    final about = clinic['about_clinic'] ?? 'No description available.';
    final address = clinic['address'] ?? 'Address not available';
    final contactNumber = clinic['contact_number'] ?? 'Not specified';
    final lat = clinic['latitude'] ?? "0.0";
    final long = clinic['longitude'] ?? "0.0";

    // Handle relative logo path
    String? imageUrl = ApiConstants.resolveImageUrl(clinic['logo']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ClinicOS',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchClinicDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHeaderCard(clinicName, clinicType, imageUrl),
              SizedBox(height: 20),
              _buildContactAddressCard(contactNumber, address, "$lat, $long"),
              SizedBox(height: 20),
              _buildAboutCard(about),
              SizedBox(height: 20),
              _buildWorkingHoursCard(clinic['working_hours']),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String name, String type, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EDF2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + Name/Badge Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clinic Logo
              HiddenStaffLoginTrigger(
                child: Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8EDF2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: imageUrl != null && imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: (imageUrl == null || imageUrl.isEmpty)
                      ? Icon(
                          Icons.business_rounded,
                          size: 44,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 16),

              // Name, Badge & Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row with ACTIVE CLINIC badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.manrope(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Active badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: const Color(0xFFDBEAFE)),
                          ),
                          child: Text(
                            'ACTIVE CLINIC',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2563EB),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Clinic type / description
                    Text(
                      type.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Full-width Edit Clinic Profile button
        ],
      ),
    );
  }

  Widget _buildContactAddressCard(String phone, String address, String coords) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.contact_support_rounded,
                  color: Color(0xFF0EA5E9),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Contact & Address',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoBox('PHONE NUMBER', phone, Icons.phone_outlined),
          SizedBox(height: 16),
          _buildInfoBox(
            'LOCATION ADDRESS',
            address,
            Icons.location_on_outlined,
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GEOGRAPHIC COORDINATES',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      coords,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openMap(coords),
                    icon: Icon(Icons.map_outlined, size: 18),
                    label: Text('Open in Google Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primaryContainer,
                      elevation: 0,
                      side: BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primaryContainer, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primaryContainer,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'About the Clinic',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF64748B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursCard(dynamic hoursData) {
    final List<Map<String, dynamic>> days = [];

    if (hoursData is Map) {
      final List<String> dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      for (var day in dayNames) {
        String time =
            hoursData[day.toLowerCase()]?.toString() ?? 'Not specified';

        final isClosed =
            time.toLowerCase().contains('closed') ||
            time.toLowerCase().contains('close');
        days.add({'day': day, 'time': time, 'isClosed': isClosed});
      }
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.alarm_on_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Working Hours',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ...days.map((day) {
            final bool isClosed = day['isClosed'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isClosed
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isClosed
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Row(
                  children: [
                    // Status Dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isClosed
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isClosed
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF22C55E))
                                    .withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      flex: 5, // Balanced flex to allow "Wednesday" to fit
                      child: Text(
                        day['day'],
                        style: GoogleFonts.inter(
                          fontSize:
                              12.5, // Slightly smaller to prevent wrapping
                          fontWeight: FontWeight.w600,
                          color: isClosed
                              ? const Color(0xFF991B1B)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      flex: 12, // More room for the timing string
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: day['time']
                              .toString()
                              .split(',')
                              .map<Widget>((t) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    t.trim(),
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isClosed
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 24),
          // Subtle Divider
          Container(
            height: 1,
            width: double.infinity,
            color: const Color(0xFFF1F5F9),
          ),
          SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(width: 6),
                Text(
                  'Last Updated: May 07, 2026',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
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
