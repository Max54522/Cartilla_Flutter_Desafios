import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  @override
  Widget build(BuildContext context) {
    // La caja de Hive que abrimos en main.dart
    final box = Hive.box('preferencias');

    // Leer los valores guardados (false si todavía no existen)
    final bool modoOscuro     = box.get('modoOscuro',     defaultValue: false);
    final bool notificaciones = box.get('notificaciones', defaultValue: true);

    return Scaffold(
      appBar: AppBar(title: Text('Configuración')),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Modo oscuro'),
            subtitle: Text('Cambia el tema de la app'),
            value: modoOscuro,
            onChanged: (bool nuevoValor) {
              // put() guarda en Hive; setState redibuja este switch
              setState(() => box.put('modoOscuro', nuevoValor));
            },
          ),
          SwitchListTile(
            title: Text('Notificaciones'),
            subtitle: Text('Recibir recordatorios de tareas'),
            value: notificaciones,
            onChanged: (bool nuevoValor) {
              setState(() => box.put('notificaciones', nuevoValor));
            },
          ),
        ],
      ),
    );
  }
}