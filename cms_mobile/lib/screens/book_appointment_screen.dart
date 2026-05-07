import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import '../theme.dart';
import '../services/appointment_api.dart';
import '../services/user_session.dart';
import '../widgets/custom_snackbar.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  final _appointmentApi = AppointmentApi();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Booking Successful!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Appointment has been scheduled for',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              _nameController.text.isEmpty ? 'Patient' : _nameController.text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'YOUR TOKEN NUMBER',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    token,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(
                    context,
                  ).pushReplacementNamed('/clinicos-overview');
                },
                child: const Text('BACK TO DASHBOARD'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'Please enter name and phone number',
        type: SnackBarType.warning,
      );
      return;
    }

    if (_phoneController.text.length != 10) {
      CustomSnackBar.show(
        context: context,
        message: 'Phone number must be 10 digits',
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _appointmentApi.bookAppointment(
        doctorId: 2, // Defaulting to 2 as per user's curl
        name: _nameController.text,
        phone: _phoneController.text,
        date: "2026-05-07", // Defaulting to the date in curl
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // log response details for debugging
        log("API Response Type: ${response.runtimeType}");
        log("API Response Data: $response");

        // Parsing token with multiple fallbacks
        String token = "108";
        if (response is Map) {
          final data = response['data'];
          if (data is Map) {
            final appointment = data['appointment'];
            if (appointment is Map) {
              token = appointment['token']?.toString() ?? "108";
            } else {
              token = data['token_number']?.toString() ?? "108";
            }
          } else if (response['token'] != null) {
            token = response['token'].toString();
          }
        }

        _showSuccessDialog(token);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = "Failed to book appointment. Please try again.";
        
        // Handle 422 Validation Errors
        if (e.toString().contains('422')) {
          try {
            final errorBody = e.toString().split(' - ').last;
            final Map<String, dynamic> decodedError = jsonDecode(errorBody);
            
            if (decodedError['errors'] != null) {
              final errors = decodedError['errors'] as Map<String, dynamic>;
              if (errors.isNotEmpty) {
                final firstKey = errors.keys.first;
                final firstErrorList = errors[firstKey] as List;
                if (firstErrorList.isNotEmpty) {
                  errorMessage = firstErrorList[0].toString();
                }
              }
            } else if (decodedError['message'] != null) {
              errorMessage = decodedError['message'];
            }
          } catch (_) {}
        }

        CustomSnackBar.show(
          context: context,
          message: errorMessage,
          type: SnackBarType.error,
        );
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
        ),
        title: Text(
          'ClinicOS',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.inputBackground, width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuATan7446xEO236IV2zZL1XnmoF-xeXXEBsquCD5GtvtL4samx82w5erZjoa8bX83NkTXmyx8V_-QmXhpEx6ZZKWM1iOY-L7kVYx-3zkYleMixNLrtf0nB4KFLSyP8XIQLAw0H5noxHK6QtfGetzP0aFnGT2u4xu4WYuljf0cRYiyk9MMONZJFGXMnmMRzwu-IJWEcq-O-4rQO9PTacPh-ZhGXqyxN1YaY55cc1LWJof0KQFVSo5xOeLuh12b51UO1D8ZbG6D7IxQc',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOOK NEW APPOINTMENT',
                      style: textTheme.labelLarge?.copyWith(letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PATIENT INFORMATION',
                            style: textTheme.labelLarge,
                          ),
                          const SizedBox(height: 16),
                          Text('FULL NAME', style: textTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              hintText: 'John Doe',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('CONTACT NUMBER', style: textTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone_outlined),
                              hintText: '+1 (555) 000-0000',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _bookAppointment,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Confirm & Book Appointment'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Review Clinic Policies',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contextual Footer
              Container(
                padding: const EdgeInsets.all(24),
                color: AppColors.inputBackground.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NEXT AVAILABLE', style: textTheme.labelLarge),
                        Text(
                          'Today, 2:30 PM',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 10),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 10),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/clinicos-overview');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/book-appointment');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'OVERVIEW',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'APPOINTMENTS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'BOOK APPOINTMENT',
          ),
        ],
      ),
    );
  }
}
