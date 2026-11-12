import '../../training/data/workout_store.dart';

class CoachTip {
  const CoachTip(this.title, this.message);
  final String title;
  final String message;
}

/// Motor de reglas local: no usa internet ni IA externa.
class CoachRules {
  CoachRules._();

  static CoachTip tipFor(List<WorkoutEntry> entries) {
    if (entries.isEmpty) {
      return const CoachTip(
        'Empecemos',
        'Todavía no registraste nada. Elegí un ejercicio en Entrenar y cargá tu primera serie.',
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = entries.first.date;
    final lastDay = DateTime(last.year, last.month, last.day);
    final daysSince = today.difference(lastDay).inDays;

    if (daysSince == 0) {
      return const CoachTip(
        '¡Buen trabajo hoy!',
        'Ya entrenaste hoy. Hidratate bien y descansá para recuperar los músculos.',
      );
    }
    if (daysSince >= 4) {
      return CoachTip(
        'Te extrañamos',
        'Pasaron $daysSince días sin entrenar. Una sesión corta hoy te ayuda a retomar el ritmo.',
      );
    }

    // Músculo/ejercicio más repetido en la última semana
    final week = entries.where((e) => now.difference(e.date).inDays < 7);
    final counts = <String, int>{};
    for (final e in week) {
      counts[e.exercise] = (counts[e.exercise] ?? 0) + 1;
    }
    if (counts.values.any((c) => c >= 4)) {
      final name = counts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      return CoachTip(
        'Variá tu rutina',
        'Hiciste "$name" muchas veces esta semana. Probá sumar otro grupo muscular para equilibrar.',
      );
    }

    return const CoachTip(
      'Vas bien',
      'Mantené la constancia. Intentá subir un poco el peso o las repeticiones en tu próximo registro.',
    );
  }
}
