import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'state/auth_provider.dart';
import 'state/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/child/add_child_screen.dart';
import 'screens/child/child_detail_screen.dart';
import 'screens/child/mood_log_screen.dart';
import 'screens/child/activities_screen.dart';
import 'screens/child/add_milestone_screen.dart';
import 'screens/child/reports_screen.dart';

class MilestoneMomentsApp extends StatelessWidget {
  const MilestoneMomentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'MilestoneMoments',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (_) => const SplashScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
            '/forgot-password': (_) => const ForgotPasswordScreen(),
            '/dashboard': (_) => const DashboardScreen(),
            '/add-child': (_) => const AddChildScreen(),
            '/child-detail': (_) => const ChildDetailScreen(),
            '/mood-log': (_) => const MoodLogScreen(),
            '/activities': (_) => const ActivitiesScreen(),
            '/add-milestone': (_) => const AddMilestoneScreen(),
            '/reports': (_) => const ReportsScreen(),
          },
        );
      },
    );
  }
}
