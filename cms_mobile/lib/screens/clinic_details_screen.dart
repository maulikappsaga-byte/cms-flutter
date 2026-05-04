import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ClinicDetailsScreen extends StatelessWidget {
  const ClinicDetailsScreen({super.key});

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
          'Clinic Details',
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
            // Clinic Header Card
            _buildHeaderCard(),
            const SizedBox(height: 32),

            // Info Sections
            _buildInfoSection(
              title: 'ABOUT CLINIC',
              content:
                  'A leading healthcare facility dedicated to providing comprehensive medical services with a patient-centered approach. Equipped with state-of-the-art technology and a team of expert specialists.',
            ),
            const SizedBox(height: 24),

            _buildDetailRow(
              icon: Icons.location_on,
              title: 'Address',
              subtitle: '123 Healthcare Plaza, Medical District, NY 10001',
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              icon: Icons.access_time_filled,
              title: 'Working Hours',
              subtitle: 'Mon - Sat: 09:00 AM - 08:00 PM\nSun: Emergency Only',
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              icon: Icons.phone,
              title: 'Contact Number',
              subtitle: '+1 (555) 012-3456',
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              icon: Icons.email,
              title: 'Email Address',
              subtitle: 'info@clinicos-hms.com',
            ),
            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text('GET DIRECTIONS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, color: AppColors.primary),
                label: const Text('CALL CLINIC'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD6E3FF), width: 3),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA__J41_xC8zaUMSCleBUb2ogdYUlz59mfLXy6O4eT-qUnHawPEDAGglm-6AS4Mp_Kzr6qsxrJh5i_NqP0C5gx-x7P4LVlsZReRmzqHaVS-YJ7AWAWSZ7PiiUrPIc-QMNZY1TSDExh2IH9UUGshLN91Gfc8Ug7_4upctS2vsWqO6gR48K5iPtq1Vr2hMJrZvbW86MavYTfNSNZiLtSSvo-IZodH-3UQACs9AnC_vaUz7qXsHErxoZ9qz25-UYCJn63GrOi8wcvwIbc',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ClinicOS Healthcare',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00478D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Multi-Specialty Medical Center',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required String title, required String content}) {
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

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 2),
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
