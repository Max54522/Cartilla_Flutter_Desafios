import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? error;
  bool cargando = false;

  Future<void> iniciarSesion() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    // Validaciones simples
    if (email.isEmpty || !email.contains('@')) {
      setState(() => error = 'Ingresá un email válido.');
      return;
    }
    if (pass.length < 6) {
      setState(() => error = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() {
      error = null;
      cargando = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      // No hace falta navegar: el StreamBuilder de main.dart
      // detecta la sesión y muestra HomeScreen.
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential': // Firebase nuevo usa este código
          mensaje = 'Email o contraseña incorrectos.';
          break;
        case 'user-disabled':
          mensaje = 'Esta cuenta fue deshabilitada.';
          break;
        case 'invalid-email':
          mensaje = 'El formato del email no es válido.';
          break;
        default:
          mensaje = 'Error al iniciar sesión.';
      }
      if (!mounted) return;
      setState(() => error = mensaje);
    }

    if (!mounted) return;
    setState(() => cargando = false);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            cargando
                ? const CircularProgressIndicator()
                : FilledButton(
              onPressed: iniciarSesion,
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistroScreen()),
                );
              },
              child: const Text('¿No tenés cuenta? Registrate'),
            ),
          ],
        ),
      ),
    );
  }
}