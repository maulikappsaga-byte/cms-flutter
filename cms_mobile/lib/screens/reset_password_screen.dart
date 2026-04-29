import 'package:flutter/material.dart';
import '../theme.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'HEALTHPORTAL',
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.lock_reset, color: AppColors.outline),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black.withOpacity(0.05), height: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 650,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(color: AppColors.primary, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Reset Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Reset Password',
                        style: textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new, highly secure password',
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.outline),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Form
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EMAIL ADDRESS', style: textTheme.labelLarge),
                          const SizedBox(height: 8),
                          const TextField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.mail_outline),
                              hintText: 'practitioner@clinicos.com',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          Text('NEW PASSWORD', style: textTheme.labelLarge),
                          const SizedBox(height: 8),
                          const TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              hintText: '••••••••••••',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('CONFIRM NEW PASSWORD', style: textTheme.labelLarge),
                          const SizedBox(height: 8),
                          const TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.verified_user_outlined),
                              hintText: '••••••••••••',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('UPDATE ACCESS'),
                              SizedBox(width: 8),
                              Icon(Icons.check_circle, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Back to Sign In
                      TextButton.icon(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: Text(
                          'BACK TO SIGN IN',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Security Badge
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.outline.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.security, size: 14, color: AppColors.outline),
                    const SizedBox(width: 8),
                    Text(
                      'SECURE CLINICAL AUTHENTICATION PROTOCOL',
                      style: textTheme.labelLarge?.copyWith(fontSize: 10, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
