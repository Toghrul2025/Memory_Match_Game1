import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final int gridSize;
  const GamePage({super.key, required this.gridSize});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<String> cards;
  List<bool> flipped = [];
  List<int> selectedIndices = [];
  int moves = 0;
  int matched = 0;
  Timer? timer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    int totalCards = widget.gridSize * widget.gridSize;
    List<String> symbols = List.generate(totalCards ~/ 2, (i) => String.fromCharCode(65 + i));
    cards = [...symbols, ...symbols]..shuffle(Random());
    flipped = List.generate(cards.length, (_) => false);
    moves = 0;
    matched = 0;
    seconds = 0;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  void onCardTap(int index) {
    if (flipped[index] || selectedIndices.length == 2) return;

    setState(() {
      flipped[index] = true;
      selectedIndices.add(index);
    });

    if (selectedIndices.length == 2) {
      moves++;
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          int i1 = selectedIndices[0];
          int i2 = selectedIndices[1];
          if (cards[i1] != cards[i2]) {
            flipped[i1] = false;
            flipped[i2] = false;
          } else {
            matched += 2;
          }
          selectedIndices.clear();
        });

        if (matched == cards.length) {
          timer?.cancel();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('You Won!'),
              content: Text('Moves: $moves\nTime: $seconds seconds'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    startGame();
                  },
                  child: const Text('Restart'),
                ),
                TextButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Home'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width / widget.gridSize;
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Moves: $moves'),
                Text('Time: $seconds s'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.gridSize,
              ),
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () => onCardTap(index),
                  child: Card(
                    color: flipped[index] ? Colors.teal : Colors.grey,
                    child: Center(
                      child: Text(
                        flipped[index] ? cards[index] : '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
