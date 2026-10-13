import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system bar styles for polished edge-to-edge feel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase and App Check
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: const AndroidDebugProvider(),
        providerApple: const AppleDebugProvider(),
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: AndroidPlayIntegrityProvider(),
        providerApple: AppleDeviceCheckProvider(),
      );
    }
  } catch (e) {
    debugPrint('Firebase/AppCheck initialization notice: $e');
  }

  runApp(const IgotuuApp());
}

class IgotuuApp extends StatelessWidget {
  const IgotuuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'igotuu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      color: AppColors.background,
      home: const SplashScreen(),
    );
  }
}
