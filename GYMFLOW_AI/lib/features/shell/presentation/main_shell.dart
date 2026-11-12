import '../../nutrition/presentation/nutrition_screen.dart';
import '../../coach/presentation/coach_screen.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/placeholder_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import '../../training/presentation/training_screen.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  late final List<Widget> _pages = [
    HomeScreen(onGoToTraining: () => setState(() => _index = 1)),
    const TrainingScreen(),
    const CoachScreen(),
    const NutritionScreen(),
    const ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Entrenar',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_rounded),
            label: 'Coach',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Nutrición',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_rounded),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }
}
