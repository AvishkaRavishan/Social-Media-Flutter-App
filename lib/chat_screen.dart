import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch the current user's email
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return StreamBuilder(
      // Adjust the stream to filter out the current user by their email
      stream: FirebaseFirestore.instance
          .collection('users')
          // Use the '!=' operator to exclude the current user's document
          // Note: Make sure your Firestore indexes support this query
          .where('email', isNotEqualTo: currentUserEmail)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String name = data['name']; // Assuming 'name' is a field in your user document
            String email = data['email']; // Assuming 'email' is a field in your user document
            // Don't display the current user in the list
            if (email == currentUserEmail) return Container();
            return ListTile(
              title: Text(name),
              subtitle: Text(email),
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatWithUserScreen(name, email)),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class ChatWithUserScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  ChatWithUserScreen(this.userName, this.userEmail);

  @override
  _ChatWithUserScreenState createState() => _ChatWithUserScreenState();
}

class _ChatWithUserScreenState extends State<ChatWithUserScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? currentUserEmail;
  late ScrollController _scrollController; // Add ScrollController

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _scrollController = ScrollController(); // Initialize ScrollController
  }

  Stream<QuerySnapshot> _getMessagesStream() {
    print('Current user email: $currentUserEmail');
    print('Selected user email: ${widget.userEmail}');

    // Ensure we have the current user's email; otherwise, return an empty stream
    if (currentUserEmail == null) {
      return Stream.empty();
    }

    // Query to get messages where either the sender is the current user and the receiver is the selected user,
    // or the sender is the selected user and the receiver is the current user
    return FirebaseFirestore.instance
        .collection('messages')
      //   .where('senderEmail', whereIn: [
      //   [currentUserEmail, widget.userEmail],
      //   [widget.userEmail, currentUserEmail]
      // ])
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.userName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<QueryDocumentSnapshot>? messages = snapshot.data?.docs;

                if (messages == null || messages.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }

                // Scroll to the bottom when the widget builds initially
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                });

                return ListView.builder(
                  controller: _scrollController, // Assign ScrollController
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;

                    bool isCurrentUser = messageData['senderEmail'] == currentUserEmail;
                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageData['message'] ?? '',
                              style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black87),
                            ),
                            Text(
                              messageData['timestamp']?.toDate().toString() ?? '',
                              style: TextStyle(color: isCurrentUser ? Colors.white70 : Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type your message...'),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && currentUserEmail != null) {
      final messageText = _messageController.text.trim();

      await FirebaseFirestore.instance.collection('messages').add({
        'message': messageText,
        'senderEmail': currentUserEmail,
        'receiverEmail': widget.userEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [currentUserEmail!, widget.userEmail], // Include both participants
      });

      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
