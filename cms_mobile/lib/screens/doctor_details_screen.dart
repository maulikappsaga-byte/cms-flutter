import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class DoctorDetailsScreen extends StatelessWidget {
  const DoctorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Profile Card
            _buildDoctorProfileCard(),
            const SizedBox(height: 32),

            // Bio Section
            _buildSection(
              title: 'ABOUT DOCTOR',
              content:
                  'Dr. Sarah Mitchell is a board-certified Senior Consultant with over 15 years of experience in specialized healthcare. She has successfully treated thousands of patients and is known for her compassionate approach and diagnostic precision.',
            ),
            const SizedBox(height: 24),

            // Specialty & Education
            _buildInfoRow(
              icon: Icons.workspace_premium,
              title: 'Specialty',
              subtitle: 'Senior Consultant, HMS Specialist',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.school,
              title: 'Education',
              subtitle: 'MD - Johns Hopkins University School of Medicine',
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.language,
              title: 'Languages',
              subtitle: 'English, Spanish, French',
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
            _buildAvailabilityRow('Mon - Wed', '09:00 AM - 01:00 PM'),
            _buildAvailabilityRow('Thu - Fri', '02:00 PM - 06:00 PM'),
            _buildAvailabilityRow('Saturday', '10:00 AM - 12:00 PM'),
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
    );
  }

  Widget _buildDoctorProfileCard() {
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
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1559839734-2b71f1536783?auto=format&fit=crop&q=80&w=200&h=200',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dr. Sarah Mitchell',
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
              'Senior Specialist',
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

  Widget _buildAvailabilityRow(String days, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            days,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
