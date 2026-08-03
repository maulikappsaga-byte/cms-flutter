import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../services/clinic_detail_api.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
                              Icons.privacy_tip_outlined,
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
                                  'Privacy Policy',
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
                        '1. Information We Collect',
                      ),
                      _buildSectionBody(
                        context,
                        '$_clinicName collects information necessary to deliver clinical management services, including clinician credentials, patient interaction details, appointment logs, and system access activity. All sensitive health data is handled in accordance with applicable healthcare information privacy standards.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        context,
                        '2. How We Use Information',
                      ),
                      _buildSectionBody(
                        context,
                        'We utilize your data strictly to facilitate clinic administration, streamline doctor-patient workflows, maintain audit logs, and improve system performance. Your information is never sold or shared with unauthorized third parties for marketing purposes.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        context,
                        '3. Data Protection & Security',
                      ),
                      _buildSectionBody(
                        context,
                        'We implement enterprise-grade encryption (in transit and at rest), secure access controls, and strict authentication mechanisms to prevent unauthorized access, alteration, or disclosure of healthcare data.',
                      ),
                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        context,
                        '4. Patient Confidentiality & HIPAA',
                      ),
                      _buildSectionBody(
                        context,
                        'Compliance with health privacy laws and patient confidentiality regulations is embedded in our architectural design. Access to patient records is strictly role-restricted to authorized personnel.',
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
