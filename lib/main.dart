import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
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
