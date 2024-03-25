import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'post_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ChatScreen(),
    ProfileScreen(),
    PostScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.logout),
      //       onPressed: () {
      //         // Add your sign-out logic here
      //         // For example:
      //         // signOut();
      //       },
      //     ),
      //   ],
      // ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.art_track),
            label: 'Post',
          ),
        ],
      ),
    );
  }

  // Example sign-out method
  // void signOut() {
  //   // Implement your sign-out logic here
  //   // For example:
  //   FirebaseAuth.instance.signOut();
  // }
}
