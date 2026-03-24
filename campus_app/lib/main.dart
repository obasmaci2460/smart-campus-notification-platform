import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/services/api_service.dart';
import 'routes/app_routes.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/notifications/screens/notification_detail_screen.dart';
import 'features/notifications/screens/create_notification_screen.dart';
import 'features/notifications/screens/map_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/followed_notifications_screen.dart';
import 'features/profile/screens/followed_updates_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  ApiService.init();

  runApp(const CampusApp());
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kampüs Bildirim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.notifications: (context) => const NotificationsScreen(),
        '/create': (context) => const CreateNotificationScreen(),
        '/map': (context) => const MapScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/followed-notifications':
            (context) => const FollowedNotificationsScreen(),
        '/followed-updates': (context) => const FollowedUpdatesScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.notificationDetail) {
          final args = settings.arguments as int;
          return MaterialPageRoute(
            builder:
                (context) => NotificationDetailScreen(notificationId: args),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(child: Text('Route bulunamadı: ${settings.name}')),
              ),
        );
      },
    );
  }
}
