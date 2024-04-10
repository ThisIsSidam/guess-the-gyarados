import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'my_app.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('caught_pokemon');
  await Hive.openBox('pokemon_images');

  runApp(const ProviderScope(
    child: MyApp())
  );
}