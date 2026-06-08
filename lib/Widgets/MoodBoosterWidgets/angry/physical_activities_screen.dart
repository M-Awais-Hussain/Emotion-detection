import 'package:flutter/material.dart';

void showAngerExercisesDialog(BuildContext context) {
  final exercises = [
    {
      'emoji': '🥊',
      'title': 'Punching Bag / Pillow',
      'desc': 'Release aggression with controlled punches for 3-5 mins.',
    },
    {
      'emoji': '🏃‍♂️',
      'title': 'Sprint or Run',
      'desc': 'Burst running for 1-2 mins to burn adrenaline.',
    },
    {
      'emoji': '🧘‍♀️',
      'title': 'Power Yoga',
      'desc': 'Try 5 rounds of Sun Salutations to calm your mind.',
    },
    {
      'emoji': '🦵',
      'title': 'Kickboxing Moves',
      'desc': 'Shadow kickboxing for 2 mins (no equipment needed).',
    },
    {
      'emoji': '💨',
      'title': 'Deep Breathing + Squats',
      'desc': 'Inhale for 4 secs, exhale for 6 secs while squatting slowly.',
    },
  ];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        "Physical Activities to Counter Anger",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: exercises.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${exercises[index]['emoji']} ${exercises[index]['title']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercises[index]['desc'] as String,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}