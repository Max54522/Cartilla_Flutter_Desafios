import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/data/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../coach/domain/coach_rules.dart';
import '../../training/data/workout_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGoToTraining});

  /// Cambia a la pestaña Entrenar.
  final VoidCallback onGoToTraining;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final store = WorkoutStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final entries = store.entries;
        final tip = CoachRules.tipFor(entries);
        final last = entries.isEmpty ? null : entries.first;

        return Scaffold(
          appBar: AppBar(
            title: const Text('GYMFLOW AI'),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout_rounded),
                onPressed: AuthService.signOut,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StreamBuilder<User?>(
                stream: AuthService.userChanges,
                initialData: AuthService.currentUser,
                builder: (context, snap) {
                  final name = snap.data?.displayName;
                  final who = (name == null || name.isEmpty)
                      ? ''
                      : ', ${name.split(' ').first}';
                  return Text(
                    '${_greeting()}$who',
                    style: Theme.of(context).textTheme.headlineSmall,
                  );
                },
              ),
              const SizedBox(height: 4),
              const Text(
                '¿Listo para entrenar?',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Consejo del coach
              Card(
                color: AppColors.surfaceLight,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.secondary,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(tip.message),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Estadísticas
              Row(
                children: [
                  _MiniStat(
                    label: 'Registros',
                    value: '${entries.length}',
                    icon: Icons.checklist_rounded,
                  ),
                  const SizedBox(width: 12),
                  _MiniStat(
                    label: 'Volumen (kg)',
                    value: store.totalVolume.toStringAsFixed(0),
                    icon: Icons.bolt_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Último entrenamiento
              Text(
                'Último entrenamiento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: const Icon(
                    Icons.history_rounded,
                    color: AppColors.secondary,
                  ),
                  title: Text(last?.exercise ?? 'Sin registros'),
                  subtitle: Text(
                    last == null
                        ? 'Tu primer entrenamiento aparecerá acá'
                        : '${last.sets} x ${last.reps} con ${last.weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  trailing: last == null
                      ? null
                      : Text(
                          _date(last.date),
                          style: const TextStyle(color: AppColors.secondary),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: onGoToTraining,
                icon: const Icon(Icons.fitness_center_rounded),
                label: const Text('Empezar a entrenar'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.secondary),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
