import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final Function() onSignIn; // Define the callback

  LoginScreen({required this.onSignIn}); // Constructor to receive the callback

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Call the callback when the user signs in successfully
      onSignIn();
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      print(e); // Consider showing a user-friendly error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _login(context); // Pass BuildContext to _login method
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                // Fill in email and password fields with demo credentials
                _emailController.text = 'avishk678@gmail.com';
                _passwordController.text = 'Avishka123';
              },
              child: Text('Login with Demo Account'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                // Navigate to the signup screen
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
