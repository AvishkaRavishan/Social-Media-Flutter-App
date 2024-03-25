import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String imageUrl = data['imageUrl'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['caption'],
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Posted by: ${data['userEmail']}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  XFile? _selectedImage;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    try {
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) {
        // User canceled the image selection
        return;
      }

      // Check if the selected image is a valid file
      File imageFile = File(pickedImage.path);
      if (!await imageFile.exists()) {
        // File does not exist
        print('Selected image does not exist');
        return;
      }

      // Check if the selected image is in a supported format
      List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'gif'];
      String fileExtension = imageFile.path.split('.').last.toLowerCase();
      if (!supportedFormats.contains(fileExtension)) {
        // Unsupported image format
        print('Selected image format is not supported');
        return;
      }

      setState(() {
        _selectedImage = pickedImage;
      });
    } catch (e) {
      print('Error selecting image: $e');
      // Handle the error (e.g., show a snackbar or alert dialog)
    }
  }

      Future<void> _savePost(BuildContext context) async {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        String? userEmail = user?.email;

        String imageUrl = ''; // Initialize image URL

        // Upload image to Firebase Storage and get its URL if an image is selected
        if (_selectedImage != null) {
          File file = File(_selectedImage!.path);
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('images')
              .child(fileName);
          firebase_storage.UploadTask task = ref.putFile(file);
          firebase_storage.TaskSnapshot snapshot = await task;
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Add post data to Firestore
        await FirebaseFirestore.instance.collection('posts').add({
          'userEmail': userEmail,
          'caption': _captionController.text,
          'imageUrl': imageUrl, // Store the URL of the uploaded image
        });

        // Clear caption field and selected image after saving
        _captionController.clear();
        setState(() {
          _selectedImage = null;
        });

        // Navigate back to the previous screen
        Navigator.pop(context);
      } catch (error) {
        // Handle errors here
        print('Error saving post: $error');
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _selectImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20.0),
            if (_selectedImage != null)
              Image.file(File(_selectedImage!.path)),
            SizedBox(height: 20.0),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Caption',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _savePost(context),
              child: Text('Save Post'),
            ),
          ],
        ),
      ),
    );
  }
}