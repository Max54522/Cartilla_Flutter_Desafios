import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../training/data/workout_store.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final store = WorkoutStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final entries = store.entries;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Progreso'),
            actions: [
              if (entries.isNotEmpty)
                IconButton(
                  tooltip: 'Borrar historial',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: store.clear,
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _StatCard(
                    label: 'Registros',
                    value: '${entries.length}',
                    icon: Icons.checklist_rounded,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Volumen total (kg)',
                    value: store.totalVolume.toStringAsFixed(0),
                    icon: Icons.bolt_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Historial', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Todavía no registraste nada. Andá a Entrenar y cargá tu primer ejercicio.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              for (final e in entries)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(e.exercise),
                    subtitle: Text(
                      '${e.sets} x ${e.reps} con ${e.weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    trailing: Text(
                      _date(e.date),
                      style: const TextStyle(color: AppColors.secondary),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
                  color: AppColors.textPrimary,
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
