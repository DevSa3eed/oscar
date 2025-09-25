import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/navigation/auth_guard.dart';
import 'core/utils/flutter_logging_config.dart';
import 'shared/services/dependency_injection.dart';
import 'shared/services/firebase_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Flutter engine logging
  FlutterLoggingConfig.configure();

  // Note: Firebase Crashlytics configuration moved after Firebase initialization

  // Initialize Firebase - this is critical and must succeed
  bool firebaseInitialized = false;
  try {
    FlutterLoggingConfig.oscarLog(
      'Initializing Firebase...',
      category: 'LOADING',
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Verify Firebase was initialized
    final apps = Firebase.apps;
    FlutterLoggingConfig.oscarLog(
      'Firebase initialized successfully',
      category: 'SUCCESS',
    );
    FlutterLoggingConfig.oscarLog(
      'Firebase apps count: ${apps.length}',
      category: 'DATA',
    );

    firebaseInitialized = true;
  } catch (e, stackTrace) {
    // Firebase initialization failed - this is critical
    FlutterLoggingConfig.oscarLog(
      'Firebase initialization failed: $e',
      category: 'ERROR',
    );
    if (kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
    FlutterLoggingConfig.oscarLog(
      'App will run in offline mode',
      category: 'WARNING',
    );
    firebaseInitialized = false;
  }

  // Configure Firebase Crashlytics only if Firebase is available
  if (firebaseInitialized) {
    try {
      // Configure Firebase Crashlytics
      if (kDebugMode) {
        FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      }
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    } catch (e) {
      FlutterLoggingConfig.oscarLog(
        'Firebase Crashlytics not available: $e',
        category: 'WARNING',
      );
    }

    // Initialize Firebase service only if Firebase is available
    try {
      FirebaseService().initialize();
      FlutterLoggingConfig.oscarLog(
        'Firebase service initialized',
        category: 'SUCCESS',
      );
    } catch (e) {
      FlutterLoggingConfig.oscarLog(
        'Firebase service initialization failed: $e',
        category: 'WARNING',
      );
    }

    // Firebase collections are now managed by the app directly
    FlutterLoggingConfig.oscarLog(
      'Firebase ready for production use',
      category: 'SUCCESS',
    );
  } else {
    FlutterLoggingConfig.oscarLog(
      'Skipping Firebase-dependent initialization',
      category: 'WARNING',
    );
  }

  // Configure dependencies
  try {
    await configureDependencies();
    FlutterLoggingConfig.oscarLog(
      'Dependencies configured successfully',
      category: 'SUCCESS',
    );
  } catch (e) {
    FlutterLoggingConfig.oscarLog(
      'Dependency injection failed: $e',
      category: 'WARNING',
    );
  }

  runApp(const ProviderScope(child: DutyApp()));
}

class DutyApp extends StatelessWidget {
  const DutyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Oscar Duty App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter().config(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AuthWrapper(child: child!);
      },
    );
  }
}
