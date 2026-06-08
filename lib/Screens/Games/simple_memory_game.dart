import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SimpleMemoryGame extends StatefulWidget {
  const SimpleMemoryGame({super.key});

  @override
  SimpleMemoryGameState createState() => SimpleMemoryGameState();
}

class SimpleMemoryGameState extends State<SimpleMemoryGame> with TickerProviderStateMixin {
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstIndex;
  int? _secondIndex;
  bool _waiting = false;

  late List<AnimationController> _controllers;
  late List<Animation<double>> _flipAnimations;

  final List<String> _availableEmojis = [
    '🍎','🍌','🍇','🍓','🍉','🍒','🥝','🍍',
    '🥥','🍑','🍐','🍋','🍊','🍈','🍏','🍅',
    '🥑','🥕','🌽','🍆','🥔','🌶','🥒','🍄',
    '🥭','🍔','🍟','🍕','🌭','🥪','🌮','🍣',
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    // Create pairs for 8x8 grid = 64 cards / 2 = 32 pairs
    _cards = List.from(_availableEmojis.take(32))..addAll(_availableEmojis.take(32));
    _cards.shuffle();

    _flipped = List<bool>.filled(_cards.length, false);
    _matched = List<bool>.filled(_cards.length, false);

    // Init animation controllers for each card
    _controllers = List.generate(_cards.length, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
    });

    _flipAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));
    }).toList();

    _firstIndex = null;
    _secondIndex = null;
    _waiting = false;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _flipCard(int index) {
    if (_waiting || _flipped[index] || _matched[index]) return;

    if (_firstIndex == null) {
      // Flip first card
      _controllers[index].forward();
      setState(() {
        _flipped[index] = true;
        _firstIndex = index;
      });
    } else if (_secondIndex == null) {
      // Flip second card
      _controllers[index].forward();
      setState(() {
        _flipped[index] = true;
        _secondIndex = index;
        _waiting = true;
      });

      Timer(const Duration(seconds: 1), () {
        setState(() {
          // Check match
          if (_cards[_firstIndex!] == _cards[_secondIndex!]) {
            _matched[_firstIndex!] = true;
            _matched[_secondIndex!] = true;
          } else {
            // Flip back
            _controllers[_firstIndex!].reverse();
            _controllers[_secondIndex!].reverse();
            _flipped[_firstIndex!] = false;
            _flipped[_secondIndex!] = false;
          }
          _firstIndex = null;
          _secondIndex = null;
          _waiting = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int gridCount = 8;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Memory Game 8x8'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                for (var controller in _controllers) {
                  controller.dispose();
                }
                _initGame();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _flipCard(index),
            child: AnimatedBuilder(
              animation: _controllers[index],
              builder: (context, child) {
                final isHalfTurned = _flipAnimations[index].value > 0.5;
                final displayEmoji = isHalfTurned ||
                    _matched[index]
                    ? _cards[index]
                    : '❓';
                final rotationY = _flipAnimations[index].value * pi;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(rotationY),
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _matched[index]
                          ? Colors.green.shade300
                          : Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2))
                      ],
                    ),
                    child: Center(
                      child: Text(
                        displayEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
