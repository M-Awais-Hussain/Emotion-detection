import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WhackAMoleGame extends StatefulWidget {
  const WhackAMoleGame({super.key});

  @override
  WhackAMoleGameState createState() => WhackAMoleGameState();
}

class WhackAMoleGameState extends State<WhackAMoleGame> {
  static const int gridCount = 9;
  int? _moleIndex;
  int _score = 0;
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _moleIndex = _random.nextInt(gridCount);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _moleIndex = _random.nextInt(gridCount);
      });
    });
  }

  void _onTap(int index) {
    if (_moleIndex == index) {
      setState(() {
        _score++;
        _moleIndex = _random.nextInt(gridCount);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Whack A Mole'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _startGame,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            'Score: $_score',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              itemCount: gridCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final bool hasMole = _moleIndex == index;
                return GestureDetector(
                  onTap: () => _onTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasMole ? Colors.brown : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(3, 3),
                        )
                      ],
                    ),
                    child: Center(
                      child: hasMole
                          ? Icon(Icons.pest_control, size: 38, color: Colors.white)
                          : SizedBox(),
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
