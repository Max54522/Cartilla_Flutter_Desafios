import 'package:flutter/material.dart';

class Alumno {
  String nombre;
  String apellido;
  int edad;
  List<double> notas;

  Alumno(this.nombre, this.apellido, this.edad, this.notas);

  double calcularPromedio() {
    double suma = 0;
    for (double nota in notas) {
      suma += nota;
    }
    return suma / notas.length;
  }

  String estadoFinal() {
    double promedio = calcularPromedio();
    if (promedio >= 6) return 'Aprobado';
    if (promedio >= 4) return 'Recuperatorio';
    return 'Desaprobado';
  }

  @override
  String toString() => '$nombre $apellido - ${estadoFinal()}';
}

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
      home: const PantallaAlumnos(),
    );
  }
}

class PantallaAlumnos extends StatelessWidget {
  const PantallaAlumnos({super.key});

  @override
  Widget build(BuildContext context) {
    List<Alumno> alumnos = [
      Alumno('Sofía', 'Gómez', 16, [8, 9, 10]),
      Alumno('Lucas', 'Pérez', 17, [6, 7, 5]),
      Alumno('Ana', 'Torres', 16, [3, 4, 2]),
      Alumno('Mateo', 'Ruiz', 17, [5, 4, 4]),
      Alumno('Valentina', 'Díaz', 16, [10, 9, 9]),
    ];

    // Ordenar de mayor a menor promedio (EXTRA)
    alumnos.sort(
            (a, b) => b.calcularPromedio().compareTo(a.calcularPromedio()));

    Alumno mejor = alumnos.first;
    int aprobados = 0;
    int desaprobados = 0;
    for (Alumno a in alumnos) {
      if (a.estadoFinal() == 'Aprobado') aprobados++;
      if (a.estadoFinal() == 'Desaprobado') desaprobados++;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registro de alumnos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Promedio más alto: ${mejor.nombre} ${mejor.apellido} '
                  '(${mejor.calcularPromedio().toStringAsFixed(2)})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Aprobados: $aprobados   Desaprobados: $desaprobados'),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: alumnos.length,
                itemBuilder: (context, i) {
                  Alumno a = alumnos[i];
                  return ListTile(
                    title: Text(a.toString()),
                    subtitle: Text(
                        'Promedio: ${a.calcularPromedio().toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}