import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SecCallApp());
}

class SecCallApp extends StatelessWidget {
  const SecCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecCall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}