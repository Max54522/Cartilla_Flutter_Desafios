import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/workout_store.dart';

class _Exercise {
  const _Exercise(this.name, this.muscle, this.icon);
  final String name;
  final String muscle;
  final IconData icon;
}

const _catalog = <_Exercise>[
  _Exercise('Press de banca', 'Pecho', Icons.fitness_center_rounded),
  _Exercise('Sentadilla', 'Piernas', Icons.directions_walk_rounded),
  _Exercise('Peso muerto', 'Espalda y piernas', Icons.fitness_center_rounded),
  _Exercise('Dominadas', 'Espalda', Icons.accessibility_new_rounded),
  _Exercise('Press militar', 'Hombros', Icons.fitness_center_rounded),
  _Exercise('Curl de bíceps', 'Brazos', Icons.fitness_center_rounded),
  _Exercise('Fondos de tríceps', 'Brazos', Icons.accessibility_new_rounded),
  _Exercise('Plancha', 'Abdomen', Icons.self_improvement_rounded),
];

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  void _openForm(BuildContext context, _Exercise ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LogForm(exercise: ex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrenar')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _catalog.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final ex = _catalog[i];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Icon(ex.icon, color: AppColors.secondary, size: 30),
              title: Text(ex.name),
              subtitle: Text(
                ex.muscle,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              trailing: const Icon(
                Icons.add_circle_rounded,
                color: AppColors.primary,
              ),
              onTap: () => _openForm(context, ex),
            ),
          );
        },
      ),
    );
  }
}

class _LogForm extends StatefulWidget {
  const _LogForm({required this.exercise});
  final _Exercise exercise;

  @override
  State<_LogForm> createState() => _LogFormState();
}

class _LogFormState extends State<_LogForm> {
  final _sets = TextEditingController(text: '3');
  final _reps = TextEditingController(text: '10');
  final _weight = TextEditingController(text: '0');

  @override
  void dispose() {
    _sets.dispose();
    _reps.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sets = int.tryParse(_sets.text) ?? 0;
    final reps = int.tryParse(_reps.text) ?? 0;
    final weight = double.tryParse(_weight.text.replaceAll(',', '.')) ?? 0;
    if (sets <= 0 || reps <= 0) return;

    await WorkoutStore.instance.add(
      WorkoutEntry(
        exercise: widget.exercise.name,
        sets: sets,
        reps: reps,
        weight: weight,
        date: DateTime.now(),
      ),
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.exercise.name} registrado')),
    );
  }

  Widget _field(String label, TextEditingController c, {bool decimal = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: c,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.exercise.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _field('Series', _sets),
              _field('Repeticiones', _reps),
              _field('Peso (kg)', _weight, decimal: true),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Guardar')),
        ],
      ),
    );
  }
}
