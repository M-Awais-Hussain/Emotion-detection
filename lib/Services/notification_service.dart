import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/mood_improvement_dashboard.dart';
import '../main.dart';
import '../screens/main_camera.dart';

class NotificationService {
  static final List<String> boostMessages = [
    "Take a break! Boost your mood with something positive 😊",
    "A little positivity goes a long way! 🌟",
    "Smile! You're doing great! 😄",
    "Time for a mini dance break! 💃",
    "You deserve some happiness right now! ✨",
    "Boost your energy: Take a deep breath and smile! 😎",
    "Hey, remember to stay awesome today! 🌈",
    "Positive vibes only! Recharge your mood 💖",
    "You got this! Keep shining! 🌟",
    "Small joys make the biggest difference! ☀️"
  ];

  static final List<String> detectMessages = [
    "How are you feeling? Let’s detect your mood 📸",
    "Snap a quick selfie to see your mood today! 😎",
    "Check-in with your feelings, take a photo! 🖼️",
    "Curious how your mood is right now? Capture it! 🤳",
    "Time to see how you’re feeling inside! 🧠",
    "Mood check! Let EmotionEye do the magic ✨",
    "Let’s capture your current vibe! 🌈",
    "See what your expression reveals today 😄",
    "Your mood matters! Let’s check it out 📸",
    "Quick mood scan time! Ready? 🚀"
  ];

  static Future<void> scheduleNextNotification() async {
    final prefs = await SharedPreferences.getInstance();
    int sentToday = prefs.getInt("sentToday") ?? 0;
    DateTime lastDate = DateTime.tryParse(prefs.getString("lastDate") ?? "") ?? DateTime.now();

    // Reset counter at midnight
    if (lastDate.day != DateTime.now().day) {
      sentToday = 0;
      await prefs.setInt("sentToday", 0);
      await prefs.setString("lastDate", DateTime.now().toIso8601String());
    }

    if (sentToday >= 3) {
      return; // already sent 3 today
    }

    final rand = Random();

    // Pick random delay (e.g. 3–6 hours later)
    int delayMinutes = (3 * 60) + rand.nextInt(3 * 60);
    final scheduleTime = DateTime.now().add(Duration(minutes: delayMinutes));

    String type = rand.nextBool() ? "boost" : "detect";
    String message = (type == "boost")
        ? boostMessages[rand.nextInt(boostMessages.length)]
        : detectMessages[rand.nextInt(detectMessages.length)];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: rand.nextInt(100000),
        channelKey: "notification_demo",
        title: "EmotionEye",
        body: message,
        payload: {"type": type},
      ),
      schedule: NotificationCalendar(
        year: scheduleTime.year,
        month: scheduleTime.month,
        day: scheduleTime.day,
        hour: scheduleTime.hour,
        minute: scheduleTime.minute,
        second: 0,
        repeats: false,
      ),
    );

    // Save counter
    await prefs.setInt("sentToday", sentToday + 1);
    await prefs.setString("lastDate", DateTime.now().toIso8601String());
  }

  // triggers when notification is displayed
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    await scheduleNextNotification();
  }

  // triggers when action is performed on notification
  static Future<void> onActionReceiveMethod(ReceivedAction receivedAction) async {
    String? type = receivedAction.payload?['type'];

    if (type == "boost") {
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => MoodImprovementDashboard(initialMood: 'happy',)));
    } else if (type == "detect") {
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => MainCamera()));
    }
  }

  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {}
  static Future<void> onDismissActionReceiveMethod(ReceivedAction receivedAction) async {}
}
