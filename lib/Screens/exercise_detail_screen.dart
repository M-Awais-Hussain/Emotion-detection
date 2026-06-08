import 'package:flutter/material.dart';

import '../model/exercise_model.dart'; // adjust path as needed

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise; // <-- use Exercise model, not Map

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("Data received: ${exercise.title}, ${exercise.image}");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          exercise.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 0, 31, 84),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            Center(
              child: Image.asset(
                exercise.image,
                height: 250,
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 20),

            /// Title
            Text(
              exercise.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// Sections
            _buildSection("Description", exercise.description),
            _buildSection("Technique", exercise.technique),
            _buildSection("Advantages", exercise.advantages),
            _buildSection("History", exercise.history),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 0, 31, 84),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
