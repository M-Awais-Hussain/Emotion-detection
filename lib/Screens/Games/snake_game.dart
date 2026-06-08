import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  SnakeGameState createState() => SnakeGameState();
}

class SnakeGameState extends State<SnakeGame> {
  static const int rowCount = 20;
  static const int colCount = 20;
  static const int squareSize = 15;

  List<Point<int>> snake = [Point(10, 10)];
  Point<int> food = Point(5, 5);
  String direction = 'right';
  Timer? timer;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    timer?.cancel();
    gameOver = false;
    snake = [Point(10, 10)];
    direction = 'right';
    food = _randomPoint();

    timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        _moveSnake();
      });
    });
  }

  Point<int> _randomPoint() {
    final random = Random();
    Point<int> newPoint;
    do {
      newPoint = Point(random.nextInt(colCount), random.nextInt(rowCount));
    } while (snake.contains(newPoint));
    return newPoint;
  }

  void _moveSnake() {
    if (gameOver) return;

    Point<int> newHead = _newHeadPosition();
    if (_checkCollision(newHead)) {
      gameOver = true;
      timer?.cancel();
      return;
    }

    snake.insert(0, newHead);

    if (newHead == food) {
      food = _randomPoint();
    } else {
      snake.removeLast();
    }
  }

  Point<int> _newHeadPosition() {
    Point<int> currentHead = snake.first;
    switch (direction) {
      case 'right':
        return Point((currentHead.x + 1) % colCount, currentHead.y);
      case 'left':
        return Point((currentHead.x - 1 + colCount) % colCount, currentHead.y);
      case 'up':
        return Point(currentHead.x, (currentHead.y - 1 + rowCount) % rowCount);
      case 'down':
        return Point(currentHead.x, (currentHead.y + 1) % rowCount);
      default:
        return currentHead;
    }
  }

  bool _checkCollision(Point<int> point) {
    return snake.contains(point);
  }

  void _changeDirection(String newDirection) {
    if (gameOver) return;

    if ((direction == 'left' && newDirection == 'right') ||
        (direction == 'right' && newDirection == 'left') ||
        (direction == 'up' && newDirection == 'down') ||
        (direction == 'down' && newDirection == 'up')) {
      // Prevent reversal
      return;
    }
    direction = newDirection;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() => _startGame()),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: rowCount * colCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colCount,
              ),
              itemBuilder: (context, index) {
                int x = index % colCount;
                int y = index ~/ colCount;
                Point<int> point = Point(x, y);
                Color color;
                if (snake.first == point) {
                  color = Colors.greenAccent;
                } else if (snake.contains(point)) {
                  color = Colors.green;
                } else if (point == food) {
                  color = Colors.red;
                } else {
                  color = Colors.grey[900]!;
                }
                return Container(
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          ),

          //Score
          Positioned(
            top: 130,
            left: 10,
            right: 10,
              child: Column(
                children: [
                  SizedBox(height: rowCount * squareSize + 20),
                  Text('Score: ${snake.length - 1}',
                      style:TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: ElevatedButton(
                        onPressed: () => _changeDirection('up'),
                        child: Icon(Icons.arrow_upward)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () => _changeDirection('left'),
                          child: Icon(Icons.arrow_back)),
                      SizedBox(width: 20,),
                      ElevatedButton(
                          onPressed: () => _changeDirection('right'),
                          child: Icon(Icons.arrow_forward)),
                    ],
                  ),Center(
                    child: ElevatedButton(
                        onPressed: () => _changeDirection('down'),
                        child: Icon(Icons.arrow_downward)),
                  ),
                ],
              )
          ),
          if (gameOver)
            Positioned(
              left: 50,
              right: 10,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Game Over! Tap refresh to restart.',
                  style: TextStyle(fontSize: 20, color: Colors.redAccent),
                ),
              ),
            )
        ],
      ),
    );
  }
}
