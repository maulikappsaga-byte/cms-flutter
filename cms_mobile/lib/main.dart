import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/receptionist_dashboard_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/book_appointment_screen.dart';
import 'screens/book_appointment_app_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinicOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/dashboard': (context) => const ReceptionistDashboardScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/book-appointment': (context) => const BookAppointmentScreen(),
        '/book-appointment-app': (context) => const BookAppointmentAppScreen(),
      },
    );
  }
}
