import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fyp_final/Pages/GroupPage.dart';
import 'package:fyp_final/Pages/Header&Footer.dart';
import 'package:fyp_final/Pages/LocationsScreen.dart';
import 'package:fyp_final/Pages/LoginScreen.dart';
import 'package:fyp_final/Pages/SignupScreen.dart';
import 'package:fyp_final/Pages/GettingStartScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

late SharedPreferences prefs;

const String taskName = "checkUnreadNotificationsTask";
const String apiUrl = "http://192.168.1.36"; // Your local backend

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      final FlutterLocalNotificationsPlugin localNotifications =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await localNotifications.initialize(initializationSettings);

      final int userId = inputData?['userId'] ?? 0;

      log("Background task running for user $userId");

      final response = await http.get(
        Uri.parse('$apiUrl/Notification/GetUserUnreadCount/4'),
      );

      if (response.statusCode == 200) {
        final unreadCount = int.tryParse(response.body) ?? 0;

        log("Unread count: $unreadCount");

        if (unreadCount > 0) {
          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
                'unread_notifications',
                'Unread Notifications',
                channelDescription: 'Notifies about unread user notifications',
                importance: Importance.max,
                priority: Priority.high,
              );

          const NotificationDetails notificationDetails = NotificationDetails(
            android: androidDetails,
          );

          await localNotifications.show(
            0,
            '🔔 $unreadCount unread notification(s)',
            'Tap to view them.',
            notificationDetails,
          );
        }
      } else {
        log("API error: ${response.statusCode}");
      }
    } catch (e, stacktrace) {
      log("Exception in background task: $e\n$stacktrace");
    }

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'unread_notifications',
    'Unread Notifications',
    description: 'Notifies about unread notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final int? userId = prefs.getInt("userId") ?? 0;
  if (userId != null && userId > 0) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(minutes: 15),
      inputData: {"userId": userId},
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = prefs.getBool('isLogin') ?? false;

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => SignUp(),
        '/layout': (context) => HeaderAndFooter(),
        '/groups': (context) => Groups(),
        '/location': (context) => LocationsScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn ? HeaderAndFooter() : GetStarted(),
    );
  }
}
