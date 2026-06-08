import 'package:flutter/material.dart';
import 'Games/rock_paper_scissors_game.dart';
import 'Games/simple_memory_game.dart';
import 'Games/simple_whack_a_mole.dart';
import 'Games/snake_game.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  static const Color primaryBlue = Color.fromARGB(255, 0, 31, 84);

  @override
  Widget build(BuildContext context) {
    final games = [
      
      {
        'title': 'Rock Paper Scissors',
        'icon': Icons.sports_martial_arts,
        'widget': RockPaperScissorsGame()
      },
      {
        'title': 'Simple Memory Game',
        'icon': Icons.memory,
        'widget': SimpleMemoryGame()
      },
      {
        'title': 'Snake Game',
        'icon': Icons.adb,
        'widget': SnakeGame(),
      },
      {
        'title': 'Whack A Mole',
        'icon': Icons.pest_control,
        'widget': WhackAMoleGame(),
      },
    ];

    return Scaffold(
      backgroundColor: primaryBlue.withValues(alpha: 0.05),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Fun Games',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 4,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => game['widget'] as Widget),
                  );
                },
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          primaryBlue,
                          Colors.blueAccent.shade200,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Icon(
                            game['icon'] as IconData,
                            color: primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            game['title'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Icon(Icons.play_arrow,
                            color: Colors.white, size: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
