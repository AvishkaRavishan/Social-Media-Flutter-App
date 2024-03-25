import 'package:chat_app/home.dart';
import 'package:chat_app/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    if (isAuthenticated) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return HomeScreen();
    } else {
      return LoginScreen(onSignIn: () {
        setState(() {
          _isAuthenticated = true;
        });
      });
    }
  }
}
