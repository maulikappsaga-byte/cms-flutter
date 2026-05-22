import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _agreeToTerms = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Privacy Policy')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String getBaseUrl() {
        if (kIsWeb) return 'http://127.0.0.1:8000';
        if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
        return 'http://127.0.0.1:8000';
      }

      final baseUrl = getBaseUrl();

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {
          'X-API-KEY': 'QOOizWQhXaQpEAk2Vu0C6N2MC4LObntMtU8NGNYwVkubR0UA80ZmndwL3BECYl4q',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      if (mounted) {
        bool isSuccess = false;
        String errorMessage = 'Registration failed';

        try {
          final body = jsonDecode(response.body);
          
          if (response.statusCode >= 200 && response.statusCode < 300) {
            if (body is Map && body['status'] == false) {
              isSuccess = false;
              errorMessage = body['message'] ?? 'Registration failed';
            } else {
              isSuccess = true;
            }
          } else {
            isSuccess = false;
            if (body is Map) {
              errorMessage = body['message'] ?? errorMessage;
            } else {
              errorMessage = 'Server error: ${response.statusCode}';
            }
          }
        } catch (_) {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            isSuccess = true;
          } else {
            errorMessage = 'Server error: ${response.statusCode}';
          }
        }

        if (isSuccess) {
          Navigator.pushReplacementNamed(context, '/clinicos-overview');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Brand Header
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'HEALTHPORTAL',
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 28,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'CLINICAL PRECISION ECOSYSTEM',
                        style: textTheme.labelLarge?.copyWith(
                          letterSpacing: 2,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Register Card
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
                        Text(
                          'Create Account',
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Join the professional medical network.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        // Full Name
                        Text('FULL NAME', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'John Doe',
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Email
                        Text('EMAIL ADDRESS', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.mail_outline),
                            hintText: 'practitioner@clinic.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        // Password Grid (using Column for mobile)
                        Text('PASSWORD', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            hintText: '••••••••',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('CONFIRM PASSWORD', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.shield_outlined),
                            hintText: '••••••••',
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Terms
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: Text(
                                'I agree to Terms and Privacy Policy',
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoading) ...[
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  const Text('CREATE ACCOUNT'),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'LOG IN',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Security Assurance
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.outline.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user, size: 14, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text('HIPAA COMPLIANT', style: textTheme.labelLarge?.copyWith(fontSize: 10)),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 16, color: AppColors.outline.withValues(alpha: 0.2)),
                        const SizedBox(width: 12),
                        const Icon(Icons.lock, size: 14, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text('END-TO-END ENCRYPTED', style: textTheme.labelLarge?.copyWith(fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
