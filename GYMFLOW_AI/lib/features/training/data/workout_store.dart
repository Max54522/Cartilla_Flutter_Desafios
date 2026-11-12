import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutEntry {
  WorkoutEntry({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.date,
  });

  final String exercise;
  final int sets;
  final int reps;
  final double weight;
  final DateTime date;

  double get volume => sets * reps * weight;

  Map<String, dynamic> toJson() => {
    'exercise': exercise,
    'sets': sets,
    'reps': reps,
    'weight': weight,
    'date': date.toIso8601String(),
  };

  factory WorkoutEntry.fromJson(Map<String, dynamic> j) => WorkoutEntry(
    exercise: j['exercise'] as String,
    sets: j['sets'] as int,
    reps: j['reps'] as int,
    weight: (j['weight'] as num).toDouble(),
    date: DateTime.parse(j['date'] as String),
  );
}

class WorkoutStore extends ChangeNotifier {
  WorkoutStore._();
  static final WorkoutStore instance = WorkoutStore._();

  static const _key = 'workout_entries';
  final List<WorkoutEntry> _entries = [];

  List<WorkoutEntry> get entries => List.unmodifiable(_entries);

  double get totalVolume => _entries.fold(0, (sum, e) => sum + e.volume);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final list = jsonDecode(raw) as List;
    _entries
      ..clear()
      ..addAll(
        list.map((e) => WorkoutEntry.fromJson(e as Map<String, dynamic>)),
      );
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> add(WorkoutEntry entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _entries.clear();
    notifyListeners();
    await _save();
  }
}
