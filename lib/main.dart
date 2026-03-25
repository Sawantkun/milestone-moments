import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'state/auth_provider.dart';
import 'state/child_provider.dart';
import 'state/theme_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise services
  final notificationService = NotificationService();
  await notificationService.initialize();

  final storageService = StorageService();
  await storageService.seedSampleData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ChildProvider(storageService, notificationService),
        ),
      ],
      child: const MilestoneMomentsApp(),
    ),
  );
}
