import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_session.dart';
import '../constants/api_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _keepLoggedIn = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      //       String getBaseUrl() {
      //   if (kIsWeb) return 'http://127.0.0.1:8000';
      //   if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
      //   return 'http://127.0.0.1:8000';
      // }

      // final baseUrl = getBaseUrl();
      final response = await http.post(
        //  Uri.parse('$baseUrl/api/auth/login'),
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {
          'X-API-KEY':
              'a467c9ae749554658c974ac9bdcdef787b9cc9ece425d33e2784e36c1aa37fc1',
          // 'X-API-KEY': ApiConstants.apiKey,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (mounted) {
        bool isSuccess = false;
        String errorMessage = 'Login failed';

        try {
          final body = jsonDecode(response.body);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            if (body is Map && body['status'] == false) {
              isSuccess = false;
              errorMessage = body['message'] ?? 'Invalid credentials';
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
          String targetRoute = '/clinicos-overview';
          String role = 'patient';
          String token = 'default_token';

          try {
            String rawResponse = response.body.toLowerCase();
            if (rawResponse.contains('receptionist')) {
              targetRoute = '/dashboard';
              role = 'receptionist';
            }
            final decodedBody = jsonDecode(response.body);
            if (decodedBody is Map && decodedBody['token'] != null) {
              token = decodedBody['token'].toString();
            }
          } catch (_) {}

          await UserSession.saveLoginSession(token, role);

          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            targetRoute,
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Network error: $e')));
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: 60),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'CLINICOS',
                    style: textTheme.headlineLarge?.copyWith(
                      letterSpacing: -1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48),
              // Login Card
              Container(
                padding: const EdgeInsets.all(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Welcome back',
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Please enter your clinical credentials to continue.',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24),
                    // Email Field
                    Text('EMAIL ADDRESS', style: textTheme.labelLarge),
                    SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline),
                        hintText: 'smith@clinicos.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 24),
                    // Password Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PASSWORD', style: textTheme.labelLarge),
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        hintText: '••••••••',
                      ),
                    ),
                    SizedBox(height: 16),
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
                          activeColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text('Keep me logged in', style: textTheme.bodyMedium),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading) ...[
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                              Text('LOGIN TO DASHBOARD'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Footer
              Divider(color: Color(0xFFE2E8F0)),
              SizedBox(height: 24),
              Wrap(
                spacing: 24,
                children: [
                  Text(
                    'Privacy Policy',
                    style: textTheme.labelLarge?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    'Terms of Service',
                    style: textTheme.labelLarge?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    'Help Center',
                    style: textTheme.labelLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                '© 2024 HEALTHCARE SYSTEMS. SECURE CLINICAL PORTAL.',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.grey.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
