import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import '../theme.dart';
import '../services/appointment_api.dart';
import '../services/doctor_detail_api.dart';
import '../widgets/custom_snackbar.dart';
import '../services/user_session.dart';

class ReceptionistBookAppointmentScreen extends StatefulWidget {
  final int? doctorId;

  const ReceptionistBookAppointmentScreen({super.key, this.doctorId});

  @override
  State<ReceptionistBookAppointmentScreen> createState() => _ReceptionistBookAppointmentScreenState();
}

class _ReceptionistBookAppointmentScreenState extends State<ReceptionistBookAppointmentScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  final _appointmentApi = AppointmentApi();
  final _doctorApi = DoctorDetailApi();
  int? _doctorId;
  List<dynamic> _doctors = [];

  @override
  void initState() {
    super.initState();
    if (!UserSession.isLoggedIn || UserSession.userRole != 'receptionist') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/clinicos-overview');
      });
      return;
    }
    _fetchDoctorId();
  }

  Future<void> _fetchDoctorId() async {
    try {
      final response = await _doctorApi.getDoctors();
      if (response != null && response['status'] == true) {
        final doctors = response['data']?['doctors'];
        if (doctors is List && doctors.isNotEmpty) {
          setState(() {
            _doctors = doctors;
            _doctorId ??= widget.doctorId; // Use passed doctorId if available
          });
          log("Dynamically loaded ${_doctors.length} doctors");
        }
      }
    } catch (e) {
      log("Error fetching doctors from API: $e");
    }
  }

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
                  ).pushReplacementNamed('/dashboard');
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
    if (_doctorId == null) {
      CustomSnackBar.show(
        context: context,
        message: 'Please select a doctor before booking',
        type: SnackBarType.warning,
      );
      return;
    }

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
      final today = DateTime.now().toString().split(' ')[0];

      final response = await _appointmentApi.bookAppointment(
        doctorId: _doctorId!, 
        name: _nameController.text,
        phone: _phoneController.text,
        date: today, // Current date YYYY-MM-DD
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        log("API Response Type: ${response.runtimeType}");
        log("API Response Data: $response");

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
          } else {
            token = response['token']?.toString() ?? "108";
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
    if (!UserSession.isLoggedIn || UserSession.userRole != 'receptionist') {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBj34gfl1ao1p6j0aJinT66BSaqMfy7rFuycWGFzw8bKZ00oApXUIE15XhRpO-pJUPGGw1_xPe9f5bpzOhjE54umLrSOlJ8DKqfgxTiwkYbF8MOMjyGLoR_5yQRBgXb3AZjxOonDW5yDEGKLyWOW2m_ZdTzS-Y2KVgsTsiCSP6xc_qaWwFyusYC8qXfZBA3lgd0a6HzY0YUyDUoc1vPvNI3dVBD3OlEH2pwFwzQ59wX-inhQTtc9JQCwnI6-pfubJ9KGSAWmR66E6E',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'BOOK NEW APPOINTMENT\n(Receptionist)',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                          Center(
                            child: Text(
                              'PATIENT INFORMATION',
                              style: textTheme.labelLarge,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('SELECT DOCTOR', style: textTheme.labelLarge),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _doctorId,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.medical_services_outlined),
                              hintText: 'Choose a Doctor',
                            ),
                            items: _doctors.map((doctor) {
                              return DropdownMenuItem<int>(
                                value: int.tryParse(doctor['id'].toString()),
                                child: Text(doctor['name'] ?? 'Unknown Doctor'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _doctorId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
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
                        onPressed: _isLoading 
                            ? null 
                            : _bookAppointment,
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
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'APPOINTMENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'BOOK APPOINTMENT'),
        ],
      ),
    );
  }
}
