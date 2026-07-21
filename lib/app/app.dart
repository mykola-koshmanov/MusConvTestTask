import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../features/splash/splash_screen.dart';
import 'app_theme.dart';

class MusConvApp extends StatelessWidget {
  const MusConvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
