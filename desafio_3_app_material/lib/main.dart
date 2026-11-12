import 'package:flutter/material.dart';

const String urlFoto =
    'https://raw.githubusercontent.com/Max54522/foto-de-perfil/main/WhatsApp%20Image%202026-11-05%20at%2000.01.43.jpeg';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _modoOscuro ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        modoOscuro: _modoOscuro,
        onCambiarModo: (valor) => setState(() => _modoOscuro = valor),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool modoOscuro;
  final ValueChanged<bool> onCambiarModo;

  const HomeScreen({
    super.key,
    required this.modoOscuro,
    required this.onCambiarModo,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _seccion = 0;

  final List<String> _titulos = ['Inicio', 'Tareas', 'Perfil'];

  final List<Widget> _pantallas = const [
    InicioScreen(),
    TareasScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_seccion]),
        backgroundColor: cs.primaryContainer,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: cs.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(urlFoto),
                  ),
                  const SizedBox(height: 10),
                  Text('Maximiliano Javier Rodriguez Fabian',
                      style: TextStyle(color: cs.onPrimary, fontSize: 16)),
                  Text('mmmmaxi545.fabiannn.22@gmail.com',
                      style: TextStyle(color: cs.onPrimary, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              selected: _seccion == 0,
              onTap: () {
                setState(() => _seccion = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: const Text('Mis tareas'),
              selected: _seccion == 1,
              onTap: () {
                setState(() => _seccion = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfiguracionScreen(
                      modoOscuro: widget.modoOscuro,
                      onCambiarModo: widget.onCambiarModo,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text('Cerrar sesión', style: TextStyle(color: cs.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: _pantallas[_seccion],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: (int indice) {
          setState(() => _seccion = indice);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ── Pantalla de Inicio ───────────────────────────────────────
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner decorado
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organizá tus tareas del día',
                  style: TextStyle(color: cs.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Fila con 3 estadísticas
          const Row(
            children: [
              Expanded(child: Estadistica(numero: '5', etiqueta: 'Total')),
              SizedBox(width: 12),
              Expanded(child: Estadistica(numero: '2', etiqueta: 'Hechas')),
              SizedBox(width: 12),
              Expanded(child: Estadistica(numero: '3', etiqueta: 'Pendientes')),
            ],
          ),
        ],
      ),
    );
  }
}

class Estadistica extends StatelessWidget {
  final String numero;
  final String etiqueta;

  const Estadistica({super.key, required this.numero, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            numero,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: cs.onSecondaryContainer,
            ),
          ),
          Text(etiqueta, style: TextStyle(color: cs.onSecondaryContainer)),
        ],
      ),
    );
  }
}

// ── Pantalla de Tareas (con FloatingActionButton) ────────────
class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final List<String> _tareas = [
    'Estudiar Dart',
    'Hacer el desafío 3',
    'Subir a GitHub',
  ];

  void _agregar() {
    setState(() => _tareas.add('Nueva tarea ${_tareas.length + 1}'));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView.builder(
        itemCount: _tareas.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.task_alt, color: cs.primary),
            title: Text(_tareas[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Pantalla de Perfil ───────────────────────────────────────
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(urlFoto),
          ),
          const SizedBox(height: 16),
          const Text(
            'Maximiliano Javier Rodriguez Fabian',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Estudiante de Informática',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Pantalla de Configuración (Switch claro / oscuro) ────────
class ConfiguracionScreen extends StatefulWidget {
  final bool modoOscuro;
  final ValueChanged<bool> onCambiarModo;

  const ConfiguracionScreen({
    super.key,
    required this.modoOscuro,
    required this.onCambiarModo,
  });

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  late bool _oscuro;

  @override
  void initState() {
    super.initState();
    _oscuro = widget.modoOscuro;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro'),
            subtitle: const Text('Cambia entre tema claro y oscuro'),
            value: _oscuro,
            onChanged: (bool nuevoValor) {
              setState(() => _oscuro = nuevoValor);
              widget.onCambiarModo(nuevoValor);
            },
          ),
        ],
      ),
    );
  }
}