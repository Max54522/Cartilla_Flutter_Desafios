import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../data/auth_service.dart';
import 'login_screen.dart';

/// Decide qué mostrar: la app si hay sesión, el login si no.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.changes,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.hasData ? const MainShell() : const LoginScreen();
      },
    );
  }
}