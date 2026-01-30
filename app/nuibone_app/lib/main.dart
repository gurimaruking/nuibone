import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ble_service.dart';
import 'control_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BleService(),
      child: const NuiBoneApp(),
    ),
  );
}

class NuiBoneApp extends StatelessWidget {
  const NuiBoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NuiBone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ControlScreen(),
    );
  }
}
