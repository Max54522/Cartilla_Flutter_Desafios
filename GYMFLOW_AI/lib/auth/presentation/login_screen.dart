import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLogin = true;
  bool _hidePassword = true;
  bool _consent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isLogin && !_consent) {
      setState(() => _error = 'Tenés que aceptar el uso de IA para registrarte.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await AuthService.signIn(_email.text, _password.text);
      } else {
        await AuthService.register(_name.text, _email.text, _password.text);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgot() async {
    final messenger = ScaffoldMessenger.of(context);
    if (!_email.text.contains('@')) {
      setState(() => _error = 'Escribí tu email arriba y volvé a tocar.');
      return;
    }
    try {
      await AuthService.resetPassword(_email.text);
      messenger.showSnackBar(
        const SnackBar(content: Text('Te enviamos un email para recuperarla.')),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.secondary),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1A3A), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withAlpha(90),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.fitness_center_rounded,
                          size: 46, color: Colors.white),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'GYMFLOW AI',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Planificá. Entrená. Superate.',
                      style: TextStyle(
                        color: AppColors.secondary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: _deco('Nombre', Icons.person_rounded),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresá tu nombre'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _deco('Email', Icons.email_rounded),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Email no válido'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      decoration: _deco(
                        'Contraseña',
                        Icons.lock_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),

                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgot,
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                      ),

                    if (!_isLogin)
                      CheckboxListTile(
                        value: _consent,
                        onChanged: (v) => setState(() => _consent = v ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                        title: const Text(
                          'Acepto que mis datos de perfil y entrenamiento se usen para personalizar el coach con IA. La app no reemplaza a un profesional de la salud.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                      ),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFFF6B6B)),
                        ),
                      ),
                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                          : Text(_isLogin ? 'ENTRAR' : 'CREAR CUENTA'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        _isLogin = !_isLogin;
                        _error = null;
                      }),
                      child: Text(
                        _isLogin
                            ? '¿No tenés cuenta? Registrate'
                            : '¿Ya tenés cuenta? Iniciá sesión',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}