import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String? _resultado;      // el nombre del alumno escaneado
  bool    _activo = true;  // true = escaneando, false = pausado

  final MobileScannerController _ctrl = MobileScannerController();
  final db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Guardar la asistencia (o avisar si ya estaba registrado hoy)
  Future<void> _procesarCodigo(String codigo) async {
    if (!_activo) return;  // evitar procesar múltiples detecciones
    setState(() {
      _resultado = codigo;
      _activo    = false;
    });
    _ctrl.stop();  // pausar la cámara

    // Fecha y hora actual como texto: '2026-11-08' y '14:05'
    final ahora = DateTime.now().toString();
    final fecha = ahora.substring(0, 10);
    final hora  = ahora.substring(11, 16);

    try {
      // Buscar si este alumno ya tiene registro hoy
      final yaExiste = await db
          .collection('asistencias')
          .where('nombre', isEqualTo: codigo)
          .where('fecha', isEqualTo: fecha)
          .get();

      if (yaExiste.docs.isNotEmpty) {
        // Ya estaba registrado: notificación local de aviso
        NotificationService.mostrar(
          titulo: 'Aviso',
          cuerpo: '$codigo ya está registrado hoy',
        );
      } else {
        // Primera vez hoy: guardar
        await db.collection('asistencias').add({
          'nombre': codigo,
          'fecha':  fecha,
          'hora':   hora,
        });
      }
    } catch (e) {
      print('Error al guardar asistencia: $e');
    }
  }

  void _escanearDeNuevo() {
    setState(() {
      _resultado = null;
      _activo    = true;
    });
    _ctrl.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear asistencia'),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () => _ctrl.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _ctrl,
              onDetect: (BarcodeCapture capture) {
                if (capture.barcodes.isNotEmpty) {
                  final codigo = capture.barcodes.first.rawValue;
                  if (codigo != null) _procesarCodigo(codigo);
                }
              },
            ),
          ),
          if (_resultado != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(height: 8),
                  Text('Alumno detectado:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(_resultado!, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _escanearDeNuevo,
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text('Escanear otro alumno'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}