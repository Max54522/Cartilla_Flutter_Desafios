import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'features/nutrition/data/nutrition_store.dart';
import 'features/training/data/workout_store.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await WorkoutStore.instance.load();
  await NutritionStore.instance.load();
  runApp(const GymFlowApp());
}