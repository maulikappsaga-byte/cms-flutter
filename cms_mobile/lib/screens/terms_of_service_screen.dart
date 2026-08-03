import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../services/clinic_detail_api.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  String _clinicName = UserSession.clinicName ?? 'ClinicOS';

  @override
  void initState() {
    super.initState();
    if (UserSession.clinicName == null || UserSession.clinicName!.trim().isEmpty) {
      _fetchClinicName();
    }
  }

  Future<void> _fetchClinicName() async {
    try {
      final response = await ClinicDetailApi().getClinicDetails();
      final name = response['data']?['clinic']?['name']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        final trimmed = name.trim();
        await UserSession.saveClinicName(trimmed);
        if (mounted) {
          setState(() {
            _clinicName = trimmed;
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          _clinicName,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: Theme.of(context).colorScheme.primaryContainer,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black.withValues(alpha: 0.05),
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(color: primaryColor, width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Icon & Title
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Terms of Service',
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Last updated: August 2026',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      _buildSectionTitle(
                        context,
                        '1. Acceptance of Terms',
                      ),
                      _buildSectionBody(
                        context,
                        'By accessing or using the $_clinicName clinical management system, you agree to comply with and be bound by these Terms of Service. If you do not agree to these terms, you may not access or use the application.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        context,
                        '2. User Account Responsibilities',
                      ),
                      _buildSectionBody(
                        context,
                        'Users are responsible for maintaining the confidentiality of their clinical login credentials and for all activities that occur under their account. You must notify system administrators immediately of any unauthorized access.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        context,
                        '3. Authorized Clinical Use',
                      ),
                      _buildSectionBody(
                        context,
                        '$_clinicName is designed exclusively for authorized medical practice management, clinical scheduling, patient records maintenance, and clinic administrative workflows. Misuse or unauthorized extraction of patient data is strictly prohibited.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        context,
                        '4. System Availability & Service Levels',
                      ),
                      _buildSectionBody(
                        context,
                        'While we strive for maximum uptime and reliability, $_clinicName is provided "as available". Scheduled maintenance window notifications will be provided in advance whenever possible.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        context,
                        '5. Limitation of Liability',
                      ),
                      _buildSectionBody(
                        context,
                        '$_clinicName serves as a clinical management support system. Ultimate medical decision-making remains the sole responsibility of licensed healthcare practitioners.',
                      ),

                      const SizedBox(height: 32),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('BACK TO LOGIN'),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            textStyle: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Widget _buildSectionBody(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: Colors.black87,
            ),
      ),
    );
  }
}
