import 'package:chat_app/home.dart';
import 'package:chat_app/login_screen.dart';
import 'package:chat_app/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) => LoginScreen(onSignIn: () {  }),
        '/home': (context) => HomeScreen(),
        '/signup': (context) => SignupScreen(),

        // Add routes for other screens here
      },
    );
  }
}
