import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  int indice = 0;

  // CREATE: guarda la tarea con el userId del usuario actual
  Future<void> agregarTarea(String titulo) async {
    await db.collection('tareas').add({
      'titulo': titulo,
      'completada': false,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });
  }

  // UPDATE
  Future<void> actualizarTarea(String docId, bool completada) async {
    await db.collection('tareas').doc(docId).update({'completada': completada});
  }

  // DELETE
  Future<void> eliminarTarea(String docId) async {
    await db.collection('tareas').doc(docId).delete();
  }

  void mostrarDialogoAgregar() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva tarea'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Título'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final titulo = ctrl.text.trim();
              if (titulo.isNotEmpty) {
                agregarTarea(titulo);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Pestaña 1: lista de tareas en tiempo real
  Widget paginaTareas() {
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('tareas')
          .where('userId', isEqualTo: user.uid) // solo las del usuario actual
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('Todavía no tenés tareas'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['titulo']),
              leading: Switch(
                value: data['completada'] ?? false,
                onChanged: (val) => actualizarTarea(docs[i].id, val),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => eliminarTarea(docs[i].id),
              ),
            );
          },
        );
      },
    );
  }

  // Pestaña 2: perfil
  Widget paginaPerfil() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Text(user.email ?? 'Sin email'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis tareas')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Usuario'),
              accountEmail: Text(user.email ?? ''),
              currentAccountPicture:
              const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                // El StreamBuilder de main.dart vuelve solo al Login
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: indice == 0 ? paginaTareas() : paginaPerfil(),
      floatingActionButton: indice == 0
          ? FloatingActionButton(
        onPressed: mostrarDialogoAgregar,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: (i) => setState(() => indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tareas'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}