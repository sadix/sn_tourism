import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const TourismeApp());
}

class TourismeApp extends StatelessWidget {
  const TourismeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0E7C86));
    return MaterialApp(
      title: 'Tourisme',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}