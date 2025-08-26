import 'package:deepnotes_flutter/utils/preference_utils.dart';
import 'package:deepnotes_flutter/utils/theme_utils.dart';
import 'package:deepnotes_flutter/widgets/home_page.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = ThemeUtils.getThemeMode(); // directly from utils
  }

  void _refreshTheme() {
    setState(() {
      _themeMode = ThemeUtils.getThemeMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(
        onThemeChanged: _refreshTheme, // just refresh state
      ),
    );
  }
}
