import 'package:flutter/material.dart';
import 'main_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Emotion Detection',
      debugShowCheckedModeBanner: false,
      home: Guide(),
    );
  }
}

class Guide extends StatefulWidget {
  const Guide({super.key});

  @override
  State<Guide> createState() => _GuideState();
}

class _GuideState extends State<Guide> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            // Navigator.of(context).pop();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainHomePage(pageNumber: 1)),
                  (Route<dynamic> route) =>
              false, // This condition removes all routes
            );
          },
        ),
        backgroundColor: Color.fromARGB(255, 0, 31, 84),
        automaticallyImplyLeading: true,
        title: const Text("Guide", style: TextStyle(color: Colors.white),),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              'Getting Started:\n\n'
              '1. Capture a Photo: Use the central camera button to take a photo of your face or someone else’s.\n'
              '2. Analyze Emotion: The app will process the image and display the detected emotion on the screen.\n\n'
              'Additional Options:\n\n'
                  '- Gallery: You can also upload a photo from your gallery using the gallery icon on the left.\n'
                  '- Replay: Tap the replay button to analyze another photo.\n\n'
                  'Navigation:\n\n'
                  '- About Us: Learn more about the team behind Mood Detector.\n'
                  '- Contact Us: Reach out for support or inquiries.\n'
                  '- About App: Understand the core functionalities and purpose of the app.\n'
                  '- Guide: Access instructions on how to use the app effectively.\n\n'
                  'Tips:\n\n'
                  '- Ensure the face is clearly visible and well-lit for the best results.\n'
                  '- Explore the app’s settings for customization options.',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}