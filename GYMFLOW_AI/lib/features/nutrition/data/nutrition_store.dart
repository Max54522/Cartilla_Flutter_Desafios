import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealEntry {
  MealEntry({required this.name, required this.calories, required this.date});

  final String name;
  final int calories;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
    'date': date.toIso8601String(),
  };

  factory MealEntry.fromJson(Map<String, dynamic> j) => MealEntry(
    name: j['name'] as String,
    calories: j['calories'] as int,
    date: DateTime.parse(j['date'] as String),
  );
}

class NutritionStore extends ChangeNotifier {
  NutritionStore._();
  static final NutritionStore instance = NutritionStore._();

  static const _mealsKey = 'nutrition_meals';
  static const _waterKey = 'nutrition_water';
  static const waterGoalMl = 2500;

  final List<MealEntry> _meals = [];
  final Map<String, int> _water = {};

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get todayWater => _water[_dayKey(DateTime.now())] ?? 0;

  List<MealEntry> get todayMeals {
    final key = _dayKey(DateTime.now());
    return _meals.where((m) => _dayKey(m.date) == key).toList();
  }

  int get todayCalories => todayMeals.fold(0, (s, m) => s + m.calories);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawMeals = prefs.getString(_mealsKey);
    if (rawMeals != null) {
      final list = jsonDecode(rawMeals) as List;
      _meals
        ..clear()
        ..addAll(
          list.map((e) => MealEntry.fromJson(e as Map<String, dynamic>)),
        );
    }
    final rawWater = prefs.getString(_waterKey);
    if (rawWater != null) {
      final map = jsonDecode(rawWater) as Map<String, dynamic>;
      _water
        ..clear()
        ..addAll(map.map((k, v) => MapEntry(k, v as int)));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _mealsKey,
      jsonEncode(_meals.map((m) => m.toJson()).toList()),
    );
    await prefs.setString(_waterKey, jsonEncode(_water));
  }

  Future<void> addWater(int ml) async {
    final key = _dayKey(DateTime.now());
    _water[key] = (_water[key] ?? 0) + ml;
    notifyListeners();
    await _save();
  }

  Future<void> resetWater() async {
    _water[_dayKey(DateTime.now())] = 0;
    notifyListeners();
    await _save();
  }

  Future<void> addMeal(MealEntry meal) async {
    _meals.insert(0, meal);
    notifyListeners();
    await _save();
  }

  Future<void> removeMeal(MealEntry meal) async {
    _meals.remove(meal);
    notifyListeners();
    await _save();
  }
}