import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/nutrition_store.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  void _openMealForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _MealForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = NutritionStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final water = store.todayWater;
        final progress =
        (water / NutritionStore.waterGoalMl).clamp(0.0, 1.0).toDouble();
        final meals = store.todayMeals;

        return Scaffold(
          appBar: AppBar(title: const Text('Nutrición')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openMealForm(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Comida'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              // Agua
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 84,
                            height: 84,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 84,
                                  height: 84,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: AppColors.surfaceLight,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const Icon(Icons.water_drop_rounded,
                                    color: AppColors.secondary),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Agua de hoy',
                                    style: TextStyle(
                                        color: AppColors.textMuted)),
                                Text(
                                  '$water ml',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Meta: ${NutritionStore.waterGoalMl} ml',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('+250 ml'),
                            onPressed: () => store.addWater(250),
                          ),
                          ActionChip(
                            label: const Text('+500 ml'),
                            onPressed: () => store.addWater(500),
                          ),
                          ActionChip(
                            label: const Text('Reiniciar'),
                            onPressed: store.resetWater,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Calorías
              Card(
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  leading: const Icon(Icons.local_fire_department_rounded,
                      color: AppColors.secondary, size: 32),
                  title: Text(
                    '${store.todayCalories} kcal',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Calorías registradas hoy',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text('Comidas de hoy',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (meals.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Todavía no registraste comidas hoy. Tocá "Comida" para agregar una.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              for (final m in meals)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant_rounded,
                        color: AppColors.secondary),
                    title: Text(m.name),
                    subtitle: Text(
                      '${m.calories} kcal',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    trailing: IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => store.removeMeal(m),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'Orientación general. Para un plan alimentario personalizado, consultá a un nutricionista.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MealForm extends StatefulWidget {
  const _MealForm();

  @override
  State<_MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<_MealForm> {
  final _name = TextEditingController();
  final _kcal = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final kcal = int.tryParse(_kcal.text) ?? 0;
    if (name.isEmpty || kcal <= 0) return;

    await NutritionStore.instance.addMeal(
      MealEntry(name: name, calories: kcal, date: DateTime.now()),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  InputDecoration _deco(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );

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
          Text('Nueva comida',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: _deco('Comida')),
          const SizedBox(height: 12),
          TextField(
            controller: _kcal,
            keyboardType: TextInputType.number,
            decoration: _deco('Calorías (kcal)'),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Guardar')),
        ],
      ),
    );
  }
}