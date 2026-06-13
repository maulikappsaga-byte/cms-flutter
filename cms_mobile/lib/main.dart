import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/receptionist_dashboard_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/book_appointment_screen.dart';

import 'screens/clinicos_overview_screen.dart';
import 'screens/clinic_details_screen.dart';
import 'screens/doctor_details_screen.dart';
import 'screens/doctors_list_screen.dart';
import 'screens/receptionist_book_appointment_screen.dart';
import 'services/user_session.dart';
import 'services/pusher_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.init();
  await ThemeService.instance.init();
  ThemeService.instance.fetchAndApplyTheme();
  await PusherService().init();
  
  String initialRoute = '/clinicos-overview';
  if (UserSession.isLoggedIn && UserSession.userRole == 'receptionist') {
    initialRoute = '/dashboard';
  }
  
  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  
  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: ThemeService.instance.themeNotifier,
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'ClinicOS',
          debugShowCheckedModeBanner: false,
          theme: theme,
          initialRoute: initialRoute,
          routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/dashboard': (context) => const ReceptionistDashboardScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/book-appointment': (context) => const BookAppointmentScreen(),

        '/clinicos-overview': (context) => const ClinicosOverviewScreen(),
        '/clinic-details': (context) => const ClinicDetailsScreen(),
        '/doctor-details': (context) => const DoctorDetailsScreen(),
        '/doctors-list': (context) => const DoctorsListScreen(),
        '/receptionist-book-appointment': (context) => const ReceptionistBookAppointmentScreen(),
      },
    );
      },
    );
  }
}
