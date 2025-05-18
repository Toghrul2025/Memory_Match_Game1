import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Match Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Easy (4x4)'),
              onPressed: () {},
            ),
            ElevatedButton(
              child: const Text('Medium (6x6)'),
              onPressed: () {},
            ),
            ElevatedButton(
              child: const Text('Hard (8x8)'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
