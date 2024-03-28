import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unsaid_feelings/components/text_box.dart';
import 'package:unsaid_feelings/components/wall_post.dart';
import 'package:unsaid_feelings/helper/helper_methods.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection("Users");
  final ImagePicker _picker = ImagePicker();
  Uint8List? _image;
  String? _imageUrl;
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(
              color: Colors.grey[900],
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(newValue);
              if (newValue.trim().isNotEmpty) {
                await userCollection
                    .doc(currentUser.email)
                    .update({field: newValue});
              }
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("PROFILE"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            _imageUrl = userData['profileImage'];

            return ListView(
              children: [
                SizedBox(height: 50),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundImage: _imageUrl != null
                            ? NetworkImage(
                                _imageUrl!) // NetworkImage if _imageUrl is not null
                            : AssetImage('assets/default_avatar.jpg')
                                as ImageProvider<
                                    Object>, // AssetImage as ImageProvider if _imageUrl is null
                      ),
                      Positioned(
                        child: IconButton(
                          onPressed: () => selectImage(context),
                          icon: Icon(Icons.add_a_photo, color: Colors.grey),
                        ),
                        bottom: -10,
                        left: 80,
                      )
                    ],
                  ),
                ),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text("My Details"),
                ),
                // Placeholder for displaying user details
                MyTextBox(
                  text: userData['username'],
                  sectionName: "username",
                  onPressed: () => editField('username'),
                ),
                MyTextBox(
                  text: userData['bio'],
                  sectionName: "bio",
                  onPressed: () => editField('bio'),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text("My Posts"),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .where("UserEmail", isEqualTo: currentUser.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index];
                          final String message = post['Message'];
                          final String user = post['UserEmail'];
                          final String postID = post.id;
                          final List<String> likes =
                              List<String>.from(post['Likes'] ?? []);
                          final String time = formatDate(post['Timestamp']);
                          final String userProfileImageUrl =
                              post['UserProfileImageUrl'];
                          final String imageUrl = post['ImageUrl'];

                          return WallPost(
                            message: message,
                            user: user,
                            postID: postID,
                            likes: likes,
                            time: time,
                            userProfileImageUrl: userProfileImageUrl,
                            imageUrl: imageUrl,
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("ERROR ${snapshot.error}"),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                )

                // Placeholder for displaying user posts
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("ERROR ${snapshot.error}"),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void selectImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List img = await pickedFile.readAsBytes();
      setState(() {
        _image = img;
      });
      uploadProfileImage(context);
    }
  }

  Future<void> uploadProfileImage(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _image != null) {
      try {
        String imagePath = 'profile_images/${user.uid}.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child(imagePath);
        UploadTask uploadTask = storageReference.putData(_image!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .update({'profileImage': downloadURL});
        setState(() {
          _imageUrl = downloadURL;
        });
        print('Profile image uploaded and user document updated');
      } catch (e) {
        print('Error uploading profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload profile image.'),
          ),
        );
      }
    } else {
      print('No image selected to upload.');
    }
  }
}
