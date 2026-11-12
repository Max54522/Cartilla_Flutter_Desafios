import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();
  String? error;
  bool cargando = false;

  Future<void> registrar() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    final pass2 = pass2Ctrl.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => error = 'Ingresá un email válido.');
      return;
    }
    if (pass.length < 6) {
      setState(() => error = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (pass != pass2) {
      setState(() => error = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      error = null;
      cargando = true;
    });

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      if (!mounted) return;
      // Al registrarse ya queda con sesión iniciada: cerramos esta pantalla
      // y debajo aparece HomeScreen (por el StreamBuilder de main.dart).
      Navigator.pop(context);
      return;
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'weak-password':
          mensaje = 'La contraseña debe tener al menos 6 caracteres.';
          break;
        case 'email-already-in-use':
          mensaje = 'Este email ya está registrado.';
          break;
        case 'invalid-email':
          mensaje = 'El formato del email no es válido.';
          break;
        default:
          mensaje = 'Error al registrarse: ${e.message}';
      }
      if (!mounted) return;
      setState(() {
        error = mensaje;
        cargando = false;
      });
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
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
            const SizedBox(height: 16),
            TextField(
              controller: pass2Ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
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
              onPressed: registrar,
              child: const Text('Registrarme'),
            ),
          ],
        ),
      ),
    );
  }
}