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
import 'screens/labhuba_overview_screen.dart';
import 'screens/clinicos_overview_screen.dart';

import 'services/pusher_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PusherService().init();
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
      initialRoute: '/clinicos-overview',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/dashboard': (context) => const ReceptionistDashboardScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/book-appointment': (context) => const BookAppointmentScreen(),
        '/book-appointment-app': (context) => const BookAppointmentAppScreen(),
        '/labhuba-overview': (context) => const LabhubaOverviewScreen(),
        '/clinicos-overview': (context) => const ClinicosOverviewScreen(),
      },
    );
  }
}
