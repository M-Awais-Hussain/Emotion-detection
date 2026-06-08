import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class MoodBooster extends StatefulWidget {
  const MoodBooster({super.key});

  @override
  MoodBoosterState createState() => MoodBoosterState();
}

class MoodBoosterState extends State<MoodBooster> {
  final ConfettiController _confettiController =
  ConfettiController(duration: const Duration(seconds: 3));
  int _currentTipIndex = 0;

  final List<String> _moodTips = [
    "Take 3 deep breaths - inhale for 4 seconds, hold for 4, exhale for 6",
    "Write down 3 things you're grateful for today",
    "Stand up and stretch for 30 seconds",
    "Drink a glass of water - dehydration affects mood",
    "Think of a happy memory and relive it in your mind",
    "Name 5 things you can see around you right now",
    "Send a nice message to someone you care about",
    "Do 10 jumping jacks to get your blood flowing",
    "Listen to your favorite song and sing along",
    "Plan something fun to look forward to this week"
  ];

  final List<Map<String, dynamic>> _happyContent = [
    {
      'type': 'Joke',
      'content': 'Why don’t skeletons fight each other?\nBecause They don’t have the guts!'
    },
    {
      'type': 'Joke',
      'content': 'Why did the scarecrow win an award?\nBecause he was outstanding in his field!'
    },
    {
      'type': 'Joke',
      'content': 'What did one wall say to the other wall?\n"I’ll meet you at the corner."'
    },
    {
      'type': 'Joke',
      'content': 'Why don’t scientists trust atoms?\nBecause they make up everything!'
    },
    {
      'type': 'Joke',
      'content': 'What do you call fake spaghetti?\nAn impasta!'
    },
    {
      'type': 'Joke',
      'content': 'Why couldn’t the bicycle stand up by itself?\nIt was two-tired.'
    },
    {
      'type': 'Joke',
      'content': 'What did the big flower say to the little flower?\n"Hey, bud!"'
    },
    {
      'type': 'Joke',
      'content': 'How does a penguin build its house?\nIgloos it together.'
    },
    {
      'type': 'Joke',
      'content': 'Why did the math book look so sad?\nBecause it had too many problems.'
    },
    {
      'type': 'Joke',
      'content': 'What did one ocean say to the other ocean?\nNothing, they just waved.'
    },
    {
      'type': 'Joke',
      'content': 'What’s orange and sounds like a parrot?\nA carrot!'
    },
    {
      'type': 'Joke',
      'content': 'Why do seagulls fly over the sea?\nBecause if they flew over the bay, they’d be bagels!'
    },
    {
      'type': 'Joke',
      'content': 'What’s a computer’s favorite snack?\nComputer chips!'
    },
    {
      'type': 'Joke',
      'content': 'Why don’t eggs tell jokes?\nBecause they’d crack each other up.'
    },
    {
      'type': 'Joke',
      'content': 'What happens when you tell an egg a joke?\nIt cracks up!'
    },
  ];


  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _moodTips.length;
    });
  }

  void _showHappyContent() {
    final random = Random();
    final randomIndex = random.nextInt(_happyContent.length);
    final content = _happyContent[randomIndex];

    _confettiController.play(); // Play confetti once

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content['type'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0240A6),
              ),
            ),
            SizedBox(height: 15),
            Text(
              content['content'],
              style: TextStyle(fontSize: 18, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0240A6),
                shape: StadiumBorder(),
              ),
              child: Text("Feeling Better!", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    ).whenComplete(() {
      _confettiController.stop();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF2FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Mood Booster', style: TextStyle(color: Color(0xFF0240A6))),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildMainContent(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 30),
            _buildMoodTipCard(),
            SizedBox(height: 30),
            _buildQuickBoosters(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.emoji_emotions_outlined, size: 80, color: Color(0xFF0240A6)),
        SizedBox(height: 10),
        Text(
          "Need a Boost?",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0240A6)),
        ),
        SizedBox(height: 8),
        Text(
          "Try these simple activities to uplift your mood!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildMoodTipCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Today's Tip",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0240A6),
              ),
            ),
            SizedBox(height: 15),
            Text(
              _moodTips[_currentTipIndex],
              style: TextStyle(fontSize: 18, height: 1.6),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _nextTip,
              icon: Icon(Icons.refresh, color: Colors.white,),
              label: Text("New Tip",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0240A6),
                shape: StadiumBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _showHappyContent,
              child: Text("Show Something Happy"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickBoosters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Mood Boosters',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0240A6),
          ),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildQuickBoosterChip('Watch a funny video'),
            _buildQuickBoosterChip('Dance for a minute'),
            _buildQuickBoosterChip('Pet an animal'),
            _buildQuickBoosterChip('Eat a snack'),
            _buildQuickBoosterChip('Call a friend'),
            _buildQuickBoosterChip('Write a journal'),
            _buildQuickBoosterChip('Look at old photos'),
            _buildQuickBoosterChip('Do a good deed'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickBoosterChip(String label) {
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(color: Color(0xFF0240A6)),
      backgroundColor: Colors.white,
      elevation: 2,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nice choice! $label')),
        );
      },
    );
  }
}
