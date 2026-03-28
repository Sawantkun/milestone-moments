import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'state/auth_provider.dart';
import 'state/child_provider.dart';
import 'state/theme_provider.dart';
import 'app.dart';

void main() {
  runZonedGuarded(_main, (error, stack) {
    debugPrint('=== UNCAUGHT ZONE ERROR ===\n$error\n$stack');
  });
}

Future<void> _main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    initError = 'dotenv: $e';
  }

  if (initError == null) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      initError = 'Firebase: $e';
    }
  }

  if (initError != null) {
    runApp(_ErrorApp(initError));
    return;
  }

  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
  } catch (e) {
    debugPrint('NotificationService init failed (non-fatal): $e');
  }

  final storageService = StorageService();

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

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp(this.message);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'Startup error:\n\n$message',
              style: const TextStyle(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
