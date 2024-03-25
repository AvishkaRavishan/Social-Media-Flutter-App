import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> getUserDetails() async {
    if (user == null) return null;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error getting user details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching user details"));
          }

          Map<String, dynamic>? userDetails = snapshot.data;
          String userName = userDetails?['name'] ?? 'No Name Provided';
          String userEmail = userDetails?['email'] ?? 'Unknown';
          String userPhone = userDetails?['phone'] ?? 'No Phone Provided';
          String userGender = userDetails?['gender'] ?? 'No Gender Provided';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20.0),
                Text(
                  'Name: $userName',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Email: $userEmail',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Phone: $userPhone',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Gender: $userGender',
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    // Sign out the user
                    FirebaseAuth.instance.signOut();

                    // Navigate back to the login screen after sign out
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  child: Text('Sign Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
