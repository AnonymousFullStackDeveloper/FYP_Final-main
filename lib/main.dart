import 'package:flutter/material.dart';
import 'package:fyp_final/Pages/GroupPage.dart';
import 'package:fyp_final/Pages/Header&Footer.dart';
import 'package:fyp_final/Pages/LocationsScreen.dart';
import 'package:fyp_final/Pages/LoginScreen.dart';
import 'package:fyp_final/Pages/Map.dart';
import 'package:fyp_final/Pages/SignupScreen.dart';
import 'package:fyp_final/Pages/GettingStartScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
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
      // home: MapScreen(userId: prefs.getInt('User_ID').toString()),
    );
  }
}
