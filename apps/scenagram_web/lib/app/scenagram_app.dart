import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/create_scene/create_scene_page.dart';
import '../features/discovery/trending_page.dart';
import '../features/profile/profile_page.dart';
import '../features/scenes/home_page.dart';

class ScenagramApp extends StatelessWidget {
  const ScenagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenagram',
      debugShowCheckedModeBanner: false,
      theme: SGTheme.light(),
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/trending': (context) => const TrendingPage(),
        '/create': (context) => const CreateScenePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
