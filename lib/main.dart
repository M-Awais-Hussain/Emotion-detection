import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'Screens/main_home_page.dart';
import 'Services/app_animations.dart';
import 'Services/notification_service.dart';
import 'Services/streak_manager.dart';
import 'Services/emotion_service.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'productivity/models/productivity_models.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load emotion model in the background so it doesn't block the splash screen
  loadEmotionModel().catchError((e) {
    debugPrint("Failed to load ONNX model: $e");
  });

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ProductivityTaskAdapter());
  Hive.registerAdapter(ProductivityGoalAdapter());
  Hive.registerAdapter(ProductivityHabitAdapter());
  Hive.registerAdapter(PomodoroSessionAdapter());

  // Open Hive boxes for Productivity Module
  await Hive.openBox<ProductivityTask>('tasks');
  await Hive.openBox<ProductivityGoal>('goals');
  await Hive.openBox<ProductivityHabit>('habits');
  await Hive.openBox<PomodoroSession>('pomodoro_sessions');

  // Initialize Awesome Notifications with BOTH channels
  await AwesomeNotifications().initialize(
    null,
    [
      // Your existing notification channel
      NotificationChannel(
        channelGroupKey: "notification_demo_key",
        channelKey: "notification_demo",
        channelName: "Notification Demo",
        channelDescription: "Demo for local notification",
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
      // NEW: Streak reminder channel
      NotificationChannel(
        channelKey: 'streak_reminder',
        channelName: 'Streak Reminders',
        channelDescription: 'Daily streak reminder notifications',
        defaultColor: Color(0xFFFF6D00),
        ledColor: Colors.orange,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
    ],
    debug: true,
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: "notification_demo_key",
        channelGroupName: "Notification",
      ),
    ],
  );

  // Request notification permissions
  bool isNotificationAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isNotificationAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications().then((bool value) {
      debugPrint("Notification permission given: $value");
    });
  }

  // Initialize streak on app start (AFTER channel is created)
  final streakManager = StreakManager();
  await streakManager.checkAndUpdateStreak();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod: NotificationService.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationService.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationService.onDismissActionReceiveMethod,
      onActionReceivedMethod: NotificationService.onActionReceiveMethod,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Add this for notification navigation
      title: 'Emotion Detection',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// Rest of your SplashScreen code remains the same
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _slideController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _backgroundFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers with AppAnimations utility
    _lottieController = AnimationController(vsync: this);

    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimations.splashFadeIn,
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: AppAnimations.splashScaleUp,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: AppAnimations.splashSlideUp,
    );

    // Create animations using AppAnimations utility
    _fadeAnimation = AppAnimations.createFadeAnimation(
      controller: _fadeController,
      curve: AppAnimations.smoothCurve,
    );

    _scaleAnimation = AppAnimations.createScaleAnimation(
      controller: _scaleController,
      begin: 0.5,
      end: 1.0,
      curve: AppAnimations.bounceCurve,
    );

    _slideAnimation = AppAnimations.createSlideAnimation(
      controller: _slideController,
      begin: const Offset(0, 0.5),
      end: Offset.zero,
      curve: AppAnimations.enterCurve,
    );

    _backgroundFadeAnimation = AppAnimations.createFadeAnimation(
      controller: _fadeController,
      begin: 0.0,
      end: 1.0,
      curve: AppAnimations.smoothCurve,
    );

    // Start animations in sequence
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Start background fade immediately
    _fadeController.forward();

    // Delay and start scale animation
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _scaleController.forward();

    // Delay and start slide animation
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _slideController.forward();

    // Navigate after splash duration
    await Future.delayed(AppAnimations.splashDuration);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppAnimations.createFadePageRoute(
        page: const MainHomePage(pageNumber: 0),
        duration: AppAnimations.fadeTransition,
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // Deep blue
              Color(0xFF3B82F6), // Medium blue
              Color(0xFF60A5FA), // Light blue
              Color(0xFFDDD6FE), // Very light purple
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _backgroundFadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _backgroundFadeAnimation.value,
              child: Stack(
                children: [
                  // Floating particles effect
                  ...List.generate(20, (index) {
                    return AnimatedBuilder(
                      animation: _fadeController,
                      builder: (context, child) {
                        final delay = index * 0.05;
                        final animationValue = (_fadeController.value - delay).clamp(0.0, 1.0);

                        return Positioned(
                          left: (index % 4) * (MediaQuery.of(context).size.width / 4) +
                              (animationValue * 50 * (index % 2 == 0 ? 1 : -1)),
                          top: (index ~/ 4) * (MediaQuery.of(context).size.height / 5) +
                              (animationValue * 30 * (index % 3)),
                          child: Opacity(
                            opacity: (animationValue * 0.6).clamp(0.0, 0.6),
                            child: Container(
                              width: 4 + (index % 3) * 2,
                              height: 4 + (index % 3) * 2,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo container
                        SlideTransition(
                          position: _slideAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.7, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Lottie.asset(
                                    'assets/animation.json',
                                    controller: _lottieController,
                                    onLoaded: (composition) {
                                      _lottieController
                                        ..duration = composition.duration
                                        ..repeat();
                                    },
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App title with staggered animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.8),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: const Interval(0.3, 1.0, curve: AppAnimations.enterCurve),
                          )),
                          child: FadeTransition(
                            opacity: Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(CurvedAnimation(
                              parent: _fadeController,
                              curve: const Interval(0.4, 1.0, curve: AppAnimations.smoothCurve),
                            )),
                            child: Column(
                              children: [
                                Text(
                                  'Emotion Eye',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Detect • Understand • Improve',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
