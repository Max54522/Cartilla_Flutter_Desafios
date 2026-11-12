import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.purple, useMaterial3: true),
      home: const ContadorScreen(),
    );
  }
}

class ContadorScreen extends StatefulWidget {
  const ContadorScreen({super.key});

  @override
  State<ContadorScreen> createState() => _ContadorScreenState();
}

class _ContadorScreenState extends State<ContadorScreen> {
  int _contador = 0;

  void _sumar() => setState(() => _contador++);
  void _restar() => setState(() => _contador--);
  void _resetear() => setState(() => _contador = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_contador',
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                onPressed: _restar,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Icon(Icons.remove, size: 28),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _sumar,
                child: const Icon(Icons.add, size: 28),
              ),
            ]),
            TextButton(onPressed: _resetear, child: const Text('Resetear')),
          ],
        ),
      ),
    );
  }
}