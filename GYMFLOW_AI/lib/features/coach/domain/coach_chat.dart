import '../../training/data/workout_store.dart';

/// Motor de respuestas por reglas. No usa internet ni IA externa.
class CoachChat {
  CoachChat._();

  static const _groups = <String, String>{
    'Press de banca': 'empuje',
    'Press militar': 'empuje',
    'Fondos de tríceps': 'empuje',
    'Dominadas': 'tirón',
    'Curl de bíceps': 'tirón',
    'Peso muerto': 'tirón',
    'Sentadilla': 'piernas',
    'Plancha': 'core',
  };

  static const _groupExamples = <String, String>{
    'empuje': 'Press de banca, Press militar o Fondos de tríceps',
    'tirón': 'Dominadas, Curl de bíceps o Peso muerto',
    'piernas': 'Sentadilla',
    'core': 'Plancha',
  };

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  static bool _has(String text, List<String> words) =>
      words.any((w) => text.contains(w));

  static String reply(String input, List<WorkoutEntry> entries) {
    final t = _norm(input);

    // Seguridad primero
    if (_has(t, ['dolor', 'duele', 'mareo', 'marea', 'pecho', 'lesion', 'desmayo'])) {
      return 'Si sentís dolor agudo, mareos o presión en el pecho, frená el entrenamiento y consultá a un profesional de la salud. '
          'Soy un asistente de la app, no un médico, y no puedo diagnosticar ni indicar tratamientos.';
    }

    if (_has(t, ['hola', 'buenas', 'hey'])) {
      return '¡Hola! Soy tu coach. Puedo sugerirte qué entrenar, resumir tu progreso o darte consejos sobre peso, descanso e hidratación.';
    }

    if (_has(t, ['progreso', 'como voy', 'resumen', 'estadistica'])) {
      if (entries.isEmpty) {
        return 'Todavía no tenés registros. Cargá tu primer ejercicio en Entrenar y te armo un resumen.';
      }
      final volume = entries.fold<double>(0, (s, e) => s + e.volume);
      final now = DateTime.now();
      final week =
          entries.where((e) => now.difference(e.date).inDays < 7).length;
      return 'Llevás ${entries.length} registros y ${volume.toStringAsFixed(0)} kg de volumen total. '
          'Esta semana hiciste $week registro(s). Último ejercicio: ${entries.first.exercise}.';
    }

    if (_has(t, ['rutina', 'que entreno', 'que hago', 'que ejercicio', 'recomend'])) {
      return _suggestRoutine(entries);
    }

    if (_has(t, ['subir', 'peso', 'carga', 'progresion', 'estanc'])) {
      return 'Para progresar: si completás todas las repeticiones con buena técnica, subí el peso entre 2% y 5% en la próxima sesión. '
          'Si no llegás, mantené la carga hasta lograrlo. Nunca sacrifiques la técnica por más peso.';
    }

    if (_has(t, ['descanso', 'descansar', 'dormir', 'recuper'])) {
      return 'Descansá 48 horas antes de volver a trabajar el mismo grupo muscular y buscá dormir entre 7 y 9 horas. '
          'Entre series, 60 a 90 segundos para hipertrofia y 2 a 3 minutos para fuerza.';
    }

    if (_has(t, ['agua', 'hidrat', 'tomar'])) {
      return 'Tomá agua durante todo el día y antes, durante y después de entrenar. Una referencia general es 2 a 3 litros diarios, según tu actividad y el clima.';
    }

    if (_has(t, ['comer', 'proteina', 'dieta', 'comida', 'adelgazar', 'bajar de peso'])) {
      return 'Orientación general: incluí una fuente de proteína en cada comida, verduras, hidratos de calidad y evitá saltearte comidas antes de entrenar. '
          'Para un plan alimentario personalizado, consultá a un nutricionista.';
    }

    if (_has(t, ['gracias', 'genial', 'buenisimo'])) {
      return '¡De nada! A seguir entrenando. 💪';
    }

    return 'No estoy seguro de entender. Probá preguntarme: "¿qué entreno hoy?", "¿cómo voy?", "¿cómo subo el peso?", "descanso" o "agua".';
  }

  static String _suggestRoutine(List<WorkoutEntry> entries) {
    final now = DateTime.now();
    final counts = <String, int>{
      for (final g in _groupExamples.keys) g: 0,
    };
    for (final e in entries) {
      if (now.difference(e.date).inDays < 7) {
        final g = _groups[e.exercise];
        if (g != null) counts[g] = counts[g]! + 1;
      }
    }
    final target =
        counts.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
    final examples = _groupExamples[target];
    if (entries.isEmpty) {
      return 'Para arrancar te sugiero un día de $target: $examples. Hacé 3 series de 10 repeticiones con un peso moderado.';
    }
    return 'Mirando tus últimos 7 días, el grupo que menos trabajaste es $target. '
        'Hoy podrías hacer: $examples. Probá 3 series de 8 a 12 repeticiones.';
  }
}