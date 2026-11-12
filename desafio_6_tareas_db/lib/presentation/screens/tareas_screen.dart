import 'package:flutter/material.dart';
import '../../data/local/local_database.dart';
import '../../domain/entities/tarea.dart';
import 'config_screen.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final LocalDatabase _db = LocalDatabase();
  final TextEditingController _tituloCtrl = TextEditingController();
  List<Tarea> _tareas = [];

  @override
  void initState() {
    super.initState();
    _cargar();   // leer las tareas guardadas al abrir la pantalla
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    super.dispose();
  }

  // Leer todas las tareas de SQLite y redibujar la pantalla
  Future<void> _cargar() async {
    final lista = await _db.obtenerTodas();
    setState(() => _tareas = lista);
  }

  Future<void> _agregar() async {
    final titulo = _tituloCtrl.text.trim();
    if (titulo.isEmpty) return;   // no agregar tareas vacías

    await _db.insertar(Tarea(titulo: titulo, fecha: '${DateTime.now()}'));
    _tituloCtrl.clear();
    _cargar();
  }

  Future<void> _toggle(Tarea tarea) async {
    // copyWith crea una copia con 'completada' invertida
    await _db.actualizar(tarea.copyWith(completada: !tarea.completada));
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis tareas'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ConfigScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── TextField + botón Agregar ───────────────────
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tituloCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nueva tarea',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _agregar,
                  child: Text('Agregar'),
                ),
              ],
            ),
          ),

          // ── Lista de tareas ─────────────────────────────
          Expanded(
            child: ListView.builder(
              itemCount: _tareas.length,
              itemBuilder: (context, index) {
                final tarea = _tareas[index];
                return Dismissible(
                  key: Key('${tarea.id}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  // Se llama cuando el usuario desliza la tarea
                  onDismissed: (direction) {
                    setState(() => _tareas.remove(tarea));
                    _db.eliminar(tarea.id!);
                  },
                  child: CheckboxListTile(
                    title: Text(
                      tarea.titulo,
                      style: TextStyle(
                        decoration: tarea.completada
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    value: tarea.completada,
                    onChanged: (valor) => _toggle(tarea),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}