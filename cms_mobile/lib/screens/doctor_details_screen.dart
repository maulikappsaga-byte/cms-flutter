import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/doctor_detail_api.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final int doctorId;
  final String name;
  final String phone;
  final String date;

  const DoctorDetailsScreen({
    super.key,
    this.doctorId = 2,
    this.name = "himanshu",
    this.phone = "1234567891",
    this.date = "2026-05-05",
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  final DoctorDetailApi _apiService = DoctorDetailApi();
  dynamic _doctorData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      final data = await _apiService.getDoctorDetails(
        doctorId: widget.doctorId,
        name: widget.name,
        phone: widget.phone,
        date: widget.date,
      );
      debugPrint('API Response: $data');
      setState(() {
        _doctorData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _fetchDoctorDetails();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Safely extract data: handle various API response formats
    dynamic data;
    try {
      if (_doctorData is List && _doctorData.isNotEmpty) {
        data = _doctorData.first;
      } else if (_doctorData is Map) {
        final nestedData = _doctorData['data'];
        if (nestedData is List && nestedData.isNotEmpty) {
          data = nestedData.first;
        } else if (nestedData is Map) {
          data = nestedData;
        } else {
          data = _doctorData;
        }
      }
    } catch (e) {
      debugPrint('Error during data extraction: $e');
    }

    debugPrint('Extracted Data: $data');

    final doctorName = (data is Map) ? (data['name'] ?? 'Doctor Name') : 'Doctor Name';
    final specialty = (data is Map) ? (data['specialization'] ?? 'Specialist') : 'Specialist';
    final about = (data is Map) ? (data['about'] ?? 'No biography available.') : 'No biography available.';
    final qualification = (data is Map) ? (data['qualification'] ?? 'N/A') : 'N/A';
    final languages = (data is Map) ? (data['languages'] ?? 'Not specified') : 'Not specified';
    final imageUrl = (data is Map) ? data['profile_photo'] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00478D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Doctor',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF00478D),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDoctorDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Profile Card
              _buildDoctorProfileCard(doctorName, specialty, imageUrl),
              const SizedBox(height: 32),

              // Bio Section
              _buildSection(
                title: 'ABOUT DOCTOR',
                content: about,
              ),
              const SizedBox(height: 24),

              // Specialty & Education
              _buildInfoRow(
                icon: Icons.workspace_premium,
                title: 'Specialty',
                subtitle: specialty,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.school,
                title: 'Qualification',
                subtitle: qualification,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.language,
                title: 'Languages',
                subtitle: languages,
              ),
              const SizedBox(height: 32),

              // Availability
              Text(
                'AVAILABILITY',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Information not provided by API',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/book-appointment-app');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'BOOK APPOINTMENT',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorProfileCard(
      String name, String specialty, String? imageUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD6E3FF), width: 4),
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (imageUrl == null || imageUrl.isEmpty)
                ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00478D),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD6E3FF).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              specialty,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.onSurface,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD6E3FF).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}
