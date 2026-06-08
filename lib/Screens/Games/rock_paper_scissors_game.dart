import 'dart:math';
import 'package:flutter/material.dart';

class RockPaperScissorsGame extends StatefulWidget {
  const RockPaperScissorsGame({super.key});

  @override
  RockPaperScissorsGameState createState() => RockPaperScissorsGameState();
}

class RockPaperScissorsGameState extends State<RockPaperScissorsGame> {
  final List<String> options = ['Rock', 'Paper', 'Scissors'];
  String? _userChoice;
  String? _botChoice;
  String _result = '';

  final Random _random = Random();

  void _play(String userChoice) {
    final botChoice = options[_random.nextInt(3)];

    setState(() {
      _userChoice = userChoice;
      _botChoice = botChoice;

      if (userChoice == botChoice) {
        _result = 'It\'s a draw!';
      } else if ((userChoice == 'Rock' && botChoice == 'Scissors') ||
          (userChoice == 'Scissors' && botChoice == 'Paper') ||
          (userChoice == 'Paper' && botChoice == 'Rock')) {
        _result = 'You win!';
      } else {
        _result = 'Bot wins!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rock Paper Scissors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Choose your move:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: options.map((e) {
                return ElevatedButton(
                  onPressed: () => _play(e),
                  child: Text(e),
                );
              }).toList(),
            ),
            SizedBox(height: 40),
            if (_userChoice != null && _botChoice != null) ...[
              Text("Your choice: $_userChoice", style: TextStyle(fontSize: 18)),
              Text("Bot's choice: $_botChoice", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Text(
                _result,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
