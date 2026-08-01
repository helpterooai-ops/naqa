import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aether_file/core/constants/app_colors.dart';
import 'package:aether_file/features/splash/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const NaqaApp());
}

class NaqaApp extends StatelessWidget {
  const NaqaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نقـــا',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        fontFamily: 'IBMPlexSansArabic',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.cardDark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
