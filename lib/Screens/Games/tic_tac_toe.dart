import 'dart:math';
import 'package:flutter/material.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  TicTacToeGameState createState() => TicTacToeGameState();
}

class TicTacToeGameState extends State<TicTacToeGame> {
  List<String> _board = List.filled(9, '');
  bool _userTurn = true; // true means user's turn, false means bot's turn
  String _winner = '';

  final Random _random = Random();

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _userTurn = true;
      _winner = '';
    });
  }

  void _makeUserMove(int index) {
    if (_board[index] != '' || _winner != '' || !_userTurn) return;

    setState(() {
      _board[index] = 'X';
      _userTurn = false;
      _winner = _checkWinner();
    });

    if (_winner == '') {
      Future.delayed(Duration(milliseconds: 500), () {
        _makeBotMove();
      });
    }
  }

  void _makeBotMove() {
    if (_winner != '') return;

    List<int> available = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        available.add(i);
      }
    }

    if (available.isEmpty) return;

    int chosenIndex = available[_random.nextInt(available.length)];
    setState(() {
      _board[chosenIndex] = 'O';
      _userTurn = true;
      _winner = _checkWinner();
    });
  }

  String _checkWinner() {
    final lines = [
      [0,1,2],[3,4,5],[6,7,8], // rows
      [0,3,6],[1,4,7],[2,5,8], // cols
      [0,4,8],[2,4,6]          // diagonals
    ];

    for (var line in lines) {
      if (_board[line[0]] != ''
          && _board[line[0]] == _board[line[1]]
          && _board[line[1]] == _board[line[2]]) {
        return _board[line[0]];
      }
    }

    if (!_board.contains('')) return 'Draw';

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetGame,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _winner == ''
                ? (_userTurn ? 'Your turn (X)' : 'Bot\'s turn (O)')
                : _winner == 'Draw'
                ? 'Game Drawn'
                : 'Winner: $_winner',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _makeUserMove(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      _board[index],
                      style: TextStyle(fontSize: 48, color: Colors.black87),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
