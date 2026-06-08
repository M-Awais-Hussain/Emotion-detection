import 'dart:math';
import 'package:flutter/material.dart';

class NumberGuessingGame extends StatefulWidget {
  const NumberGuessingGame({super.key});

  @override
  NumberGuessingGameState createState() => NumberGuessingGameState();
}

class NumberGuessingGameState extends State<NumberGuessingGame> {
  final int _target = Random().nextInt(100) + 1;
  final TextEditingController _controller = TextEditingController();
  String _message = '';
  int _attempts = 0;

  void _checkGuess() {
    final guess = int.tryParse(_controller.text);
    if (guess == null) {
      setState(() {
        _message = 'Please enter a valid number';
      });
      return;
    }

    setState(() {
      _attempts++;
      if (guess < _target) {
        _message = 'Try Higher!';
      } else if (guess > _target) {
        _message = 'Try Lower!';
      } else {
        _message = 'Correct! You guessed in $_attempts tries.';
      }
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Guessing Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Guess a number between 1 and 100',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your guess',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkGuess,
              child: Text('Check'),
            ),
            SizedBox(height: 16),
            Text(
              _message,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
