import 'package:chat_app/message.dart';
import 'package:chat_app/post.dart';
import 'package:chat_app/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example method to save a message to Firestore
  Future<void> saveMessage(Message message) async {
    try {
      await _firestore.collection('messages').add(message.toMap());
    } catch (e) {
      print("Error saving message: $e");
    }
  }

  // Example method to save a post to Firestore
  Future<void> savePost(Post post) async {
    try {
      await _firestore.collection('posts').add(post.toMap());
    } catch (e) {
      print("Error saving post: $e");
    }
  }

  // Example method to update user profile in Firestore
  Future<void> updateUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  // Example method to fetch user's posts from Firestore
  Future<List<Post>> getUserPosts(String userId) async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('posts').where('userId', isEqualTo: userId).get();
    return querySnapshot.docs
        .map((doc) => Post.fromMap(doc.data() as Map<String, dynamic>? ?? {}))
        .toList();
  } catch (e) {
    print("Error fetching user posts: $e");
    return [];
  }
}


  // Example method to fetch messages from Firestore
  Future<List<Message>> getMessages() async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('messages').get();
    return querySnapshot.docs
        .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>? ?? {}))
        .toList();
  } catch (e) {
    print("Error fetching messages: $e");
    return [];
  }
}
}