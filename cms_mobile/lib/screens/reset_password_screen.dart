import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_api.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;
  bool _emailInitialized = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_emailInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _emailController.text = args;
      }
      _emailInitialized = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpControllers.map((c) => c.text).join();
    final password = _passwordController.text;
    final passwordConfirmation = _confirmPasswordController.text;

    if (email.isEmpty || otp.length < 6 || password.isEmpty || passwordConfirmation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (password != passwordConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthApi.resetPassword(
        email,
        otp,
        password,
        passwordConfirmation,
      );

      if (mounted) {
        if (response is Map && response['status'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to reset password'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          String successMessage = 'Password updated successfully!';
          if (response is Map && response['message'] != null) {
            successMessage = response['message'];
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to reset password';
        final errorString = e.toString();
        if (errorString.contains('{')) {
          try {
            final jsonStr = errorString.substring(errorString.indexOf('{'));
            final body = jsonDecode(jsonStr);
            if (body is Map) {
              if (body['errors'] != null && body['errors'] is Map) {
                final errors = body['errors'] as Map;
                if (errors.isNotEmpty) {
                  final firstError = errors.values.first;
                  errorMessage = firstError is List ? firstError[0].toString() : firstError.toString();
                }
              } else if (body['message'] != null) {
                errorMessage = body['message'];
              }
            }
          } catch (_) {}
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        title: Text(
          'ClinicOS',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: Theme.of(context).colorScheme.primaryContainer,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black.withValues(alpha: 0.05), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
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
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      'Reset Password',
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a new, highly secure password',
                      style: textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    // Form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EMAIL ADDRESS', style: textTheme.labelLarge),
                        SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.mail_outline),
                            hintText: 'practitioner@clinicos.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 24),
                        Text('VERIFICATION CODE (6-DIGIT)', style: textTheme.labelLarge),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: TextField(
                                  controller: _otpControllers[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      FocusScope.of(context).nextFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      FocusScope.of(context).previousFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text('NEW PASSWORD', style: textTheme.labelLarge),
                        SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: '••••••••••••',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Text('CONFIRM NEW PASSWORD', style: textTheme.labelLarge),
                        SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.verified_user_outlined),
                            hintText: '••••••••••••',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading) ...[
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                              ],
                              Text('UPDATE ACCESS'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Back to Sign In
                    TextButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Text(
                        'BACK TO SIGN IN',
                        style: textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              SizedBox(height: 32),
              // Security Badge
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, size: 14, color: Theme.of(context).colorScheme.outline),
                    SizedBox(width: 8),
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
      );
    }
}
