import 'package:flutter/material.dart';

import '../main_camera.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _photoClicked = false;

  late final AnimationController _outerCircleController;
  late final AnimationController _middleCircleController;

  late final Animation<double> _outerCircleAnimation;
  late final Animation<double> _middleCircleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _outerCircleController = AnimationController(
      duration: const Duration(seconds: 4), // Fixed safe duration
      vsync: this,
    )..repeat(reverse: true);

    _middleCircleController = AnimationController(
      duration: const Duration(seconds: 5), // Different safe duration
      vsync: this,
    )..repeat(reverse: true);

    _outerCircleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(parent: _outerCircleController, curve: Curves.easeInOut),
    );

    _middleCircleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.10,
    ).animate(
      CurvedAnimation(parent: _middleCircleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _outerCircleController.dispose();
    _middleCircleController.dispose();
    super.dispose();
  }

  void _togglePhotoClicked() {
    setState(() {
      _photoClicked = !_photoClicked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [

                // Outer Circle
                AnimatedBuilder(
                  animation: _outerCircleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _outerCircleAnimation.value,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 153, 171, 201),
                        ),
                      ),
                    );
                  },
                ),

                // Middle Circle
                AnimatedBuilder(
                  animation: _middleCircleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _middleCircleAnimation.value,
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 102, 127, 178),
                        ),
                      ),
                    );
                  },
                ),

                // Main Camera Button
                SizedBox(
                  width: 150,
                  height: 150,
                  child: FloatingActionButton(
                    onPressed: () {
                      _togglePhotoClicked();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainCamera(),
                        ),
                      );
                    },
                    shape: const CircleBorder(),
                    backgroundColor: const Color.fromARGB(255, 0, 31, 84),
                    foregroundColor: Colors.white,
                    heroTag: "camera_button",
                    child: const Icon(Icons.camera_alt, size: 80),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
