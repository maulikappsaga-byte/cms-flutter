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
import 'services/subscription_service.dart';
import 'widgets/subscription_expired_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.init();
  await ThemeService.instance.init();
  ThemeService.instance.fetchAndApplyTheme();
  SubscriptionService.instance.checkSubscription();
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
          builder: (context, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: SubscriptionService.instance.isExpiredNotifier,
              builder: (context, isExpired, _) {
                return Stack(
                  children: [
                    if (child != null) child,
                    if (isExpired) const SubscriptionExpiredOverlay(),
                  ],
                );
              },
            );
          },
          onGenerateRoute: (settings) {
            final name = settings.name;

            // Check if user is an authenticated receptionist
            final isReceptionist = UserSession.isLoggedIn && UserSession.userRole == 'receptionist';

            // Define receptionist-only routes
            final receptionistRoutes = [
              '/dashboard',
              '/appointments',
              '/receptionist-book-appointment',
            ];

            // If a logged-in receptionist tries to access a non-receptionist route, redirect to dashboard
            if (isReceptionist && !receptionistRoutes.contains(name)) {
              return MaterialPageRoute(
                builder: (context) => const ReceptionistDashboardScreen(),
                settings: const RouteSettings(name: '/dashboard'),
              );
            }

            // Route mapping
            Widget page;
            switch (name) {
              case '/':
              case '/login':
                page = const LoginScreen();
                break;
              case '/forgot-password':
                page = const ForgotPasswordScreen();
                break;
              case '/reset-password':
                page = const ResetPasswordScreen();
                break;
              case '/dashboard':
                page = const ReceptionistDashboardScreen();
                break;
              case '/appointments':
                page = const AppointmentsScreen();
                break;
              case '/book-appointment':
                page = const BookAppointmentScreen();
                break;
              case '/clinicos-overview':
                page = const ClinicosOverviewScreen();
                break;
              case '/clinic-details':
                page = const ClinicDetailsScreen();
                break;
              case '/doctor-details':
                page = const DoctorDetailsScreen();
                break;
              case '/doctors-list':
                page = const DoctorsListScreen();
                break;
              case '/receptionist-book-appointment':
                page = const ReceptionistBookAppointmentScreen();
                break;
              default:
                page = isReceptionist ? const ReceptionistDashboardScreen() : const ClinicosOverviewScreen();
            }

            return MaterialPageRoute(
              builder: (context) => page,
              settings: settings,
            );
          },
    );
      },
    );
  }
}
