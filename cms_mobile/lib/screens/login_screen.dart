import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _keepLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CLINICOS',
                    style: textTheme.headlineLarge?.copyWith(
                      letterSpacing: -1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Login Card
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Welcome back',
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Please enter your clinical credentials to continue.',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Email Field
                    Text(
                      'EMAIL ADDRESS',
                      style: textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline),
                        hintText: 'dr.smith@clinicos.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    // Password Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PASSWORD',
                          style: textTheme.labelLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'FORGOT PASSWORD?',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        hintText: '••••••••',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Keep Logged In
                    Row(
                      children: [
                        Checkbox(
                          value: _keepLoggedIn,
                          onChanged: (value) {
                            setState(() {
                              _keepLoggedIn = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text(
                          'Keep me logged in',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/clinicos-overview');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('LOGIN TO DASHBOARD'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to the platform?',
                    style: textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Create Account',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Footer
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 24,
                children: [
                  Text('Privacy Policy', style: textTheme.labelLarge?.copyWith(color: Colors.grey)),
                  Text('Terms of Service', style: textTheme.labelLarge?.copyWith(color: Colors.grey)),
                  Text('Help Center', style: textTheme.labelLarge?.copyWith(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '© 2024 HEALTHCARE SYSTEMS. SECURE CLINICAL PORTAL.',
                style: textTheme.labelLarge?.copyWith(color: Colors.grey.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
