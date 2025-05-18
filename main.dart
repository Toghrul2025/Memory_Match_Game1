import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
