import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthApi.forgotPassword(email);

      if (mounted) {
        if (response is Map && response['status'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to send recovery link'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          String successMessage = 'Recovery link sent to your email!';
          if (response is Map && response['message'] != null) {
            successMessage = response['message'];
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamed(
                context,
                '/reset-password',
                arguments: email,
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to send recovery link';
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
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(32),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lock Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lock,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Password Recovery',
                        style: textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enter your email address and we\'ll send you a secure link',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      // Email Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('EMAIL ADDRESS', style: textTheme.labelLarge),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline),
                          hintText: 'pritesh@gmail.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 32),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendRecoveryLink,
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
                                Text('SEND RECOVERY LINK'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      // Back to Login
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'BACK TO LOGIN',
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
            ),
          ),
        ],
      ),
    );
  }
}
