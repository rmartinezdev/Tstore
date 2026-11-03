import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tstore/core/config/app_router.dart';
import 'package:tstore/core/config/dependency_injection.dart';
import 'package:tstore/core/config/env.dart';
import 'package:tstore/core/database/hive_database.dart';
import 'package:tstore/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize config, storage, and DI
  await Env.init();
  await HiveDatabase.init();
  await initDependencyInjection();

  runApp(
    // Riverpod ProviderScope wraps the root
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TStore Importaciones',
      debugShowCheckedModeBanner: false,
      
      // Themes (Material 3)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Auto dark/light

      // Navigation
      routerConfig: AppRouter.router,
    );
  }
}

