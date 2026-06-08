// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> requestExactAlarmPermission() async {
//   final androidPlugin = flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>();
//
//   final granted = await androidPlugin?.requestExactAlarmsPermission();
//   if (granted == false) {
//     print("⚠️ Exact alarm permission denied");
//     // You may want to fallback to non-exact alarms or guide the user to Settings
//   }
// }
