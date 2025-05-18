
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(MemoryMatchGame());

class MemoryMatchGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Match Game',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memory Match Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GamePage(gridSize: 4)),
                );
              },
              child: Text('Easy (4x4)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GamePage(gridSize: 6)),
                );
              },
              child: Text('Medium (6x6)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GamePage(gridSize: 8)),
                );
              },
              child: Text('Hard (8x8)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LeaderboardPage()),
                );
              },
              child: Text('View Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final int gridSize;
  GamePage({required this.gridSize});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<CardModel> cards;
  CardModel? firstCard;
  CardModel? secondCard;
  int moves = 0;
  int matches = 0;
  int secondsPassed = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    moves = 0;
    matches = 0;
    secondsPassed = 0;
    cards = generateCards(widget.gridSize);
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        secondsPassed++;
      });
    });
  }

  List<CardModel> generateCards(int size) {
    int numPairs = (size * size) ~/ 2;
    List<int> values = List.generate(numPairs, (index) => index);
    values += values;
    values.shuffle();
    return values.map((val) => CardModel(value: val)).toList();
  }

  void onCardTap(int index) {
    if (cards[index].isFaceUp || cards[index].isMatched) return;

    setState(() {
      cards[index].isFaceUp = true;

      if (firstCard == null) {
        firstCard = cards[index];
      } else if (secondCard == null) {
        secondCard = cards[index];
        moves++;

        if (firstCard!.value == secondCard!.value) {
          firstCard!.isMatched = true;
          secondCard!.isMatched = true;
          firstCard = null;
          secondCard = null;
          matches++;

          if (matches == cards.length ~/ 2) {
            timer?.cancel();
            saveResult(secondsPassed, moves, '${widget.gridSize}x${widget.gridSize}');
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Game Over'),
                content: Text('Time: $secondsPassed sec\nMoves: $moves'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      startGame();
                    },
                    child: Text('Restart'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    child: Text('Home'),
                  ),
                ],
              ),
            );
          }
        } else {
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              firstCard!.isFaceUp = false;
              secondCard!.isFaceUp = false;
              firstCard = null;
              secondCard = null;
            });
          });
        }
      }
    });
  }

  Future<void> saveResult(int time, int moves, String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList('results') ?? [];
    final newResult = jsonEncode({
      'time': time,
      'moves': moves,
      'difficulty': difficulty,
    });
    existing.add(newResult);
    await prefs.setStringList('results', existing);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int gridCount = widget.gridSize;
    return Scaffold(
      appBar: AppBar(
        title: Text('Moves: $moves | Time: $secondsPassed s'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return GestureDetector(
            onTap: () => onCardTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: card.isFaceUp || card.isMatched ? Colors.indigo : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: card.isFaceUp || card.isMatched
                    ? Text('${card.value}', style: TextStyle(fontSize: 20, color: Colors.white))
                    : SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList('results') ?? [];
    final results = stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    results.sort((a, b) => a['time'].compareTo(b['time']));
    return results.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadResults(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final results = snapshot.data!;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final res = results[index];
              return ListTile(
                title: Text('Difficulty: ${res['difficulty']}'),
                subtitle: Text('Time: ${res['time']} sec, Moves: ${res['moves']}'),
              );
            },
          );
        },
      ),
    );
  }
}

class CardModel {
  final int value;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.value, this.isFaceUp = false, this.isMatched = false});
}
