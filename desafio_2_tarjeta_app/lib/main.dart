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
      theme: ThemeData(colorSchemeSeed: Colors.blueAccent , useMaterial3: true),
      home: const TarjetaScreen(),
    );
  }
}

class TarjetaScreen extends StatefulWidget {
  const TarjetaScreen({super.key});

  @override
  State<TarjetaScreen> createState() => _TarjetaScreenState();
}

class _TarjetaScreenState extends State<TarjetaScreen> {
  // Guarda el estado del Switch
  bool _fondoActivo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El Switch cambia el color de fondo de la pantalla
      backgroundColor: _fondoActivo ? Colors.blueAccent .shade100 : Colors.white,
      appBar: AppBar(title: const Text('Mi tarjeta')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto circular
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://raw.githubusercontent.com/Max54522/foto-de-perfil/main/WhatsApp%20Image%202026-11-05%20at%2000.01.43.jpeg'),
            ),
            const SizedBox(height: 20),
            // Nombre completo
            const Text(
              'Maximiliano Javier Rodriguez Fabian',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Descripción o rol en gris
            const Text(
              'Estudiante de Informática',
              style: TextStyle(color: Colors.grey ),
            ),
            const SizedBox(height: 24),
            // Switch que cambia el fondo
            SwitchListTile(
              title: const Text('Cambiar color de fondo'),
              value: _fondoActivo,
              onChanged: (bool nuevoValor) {
                setState(() {
                  _fondoActivo = nuevoValor;
                });
              },
            ),
            const SizedBox(height: 16),
            // Botón que muestra el SnackBar
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Hola!')),
                );
              },
              child: const Text('Saludar'),
            ),
          ],
        ),
      ),
    );
  }
}