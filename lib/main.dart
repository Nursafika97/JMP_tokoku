import 'package:flutter/material.dart';
import 'package:tokoku/core/theme/app_theme.dart';
import 'package:tokoku/features/note/screens/home_screen.dart';
import 'package:tokoku/features/note/screens/login_screen.dart'; // pastikan file login ada
import 'package:tokoku/features/note/screens/splash_screen.dart'; // file splash_screen.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Belanjaku',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // ganti HomeScreen jadi SplashScreen
    );
  }
}
