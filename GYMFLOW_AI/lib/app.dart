import 'package:flutter/material.dart';
import 'auth/presentation/auth_gate.dart';
import 'core/theme/app_theme.dart';

class GymFlowApp extends StatelessWidget {
  const GymFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYMFLOW AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}
