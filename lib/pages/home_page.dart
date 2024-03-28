import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unsaid_feelings/components/drawer.dart';
import 'package:unsaid_feelings/components/my_textfield.dart';

import 'package:unsaid_feelings/components/wall_post.dart';
import 'package:unsaid_feelings/helper/helper_methods.dart';
import 'package:unsaid_feelings/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _fileBytes;
  String? _fileName;
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<String> getUserProfileImageUrl(String userEmail) async {
    try {
      // Retrieve the user document from the "Users" collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .get();

      // Cast the data to Map<String, dynamic>
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('profileImage')) {
        return userData['profileImage'];
      } else {
        return '';
      }
    } catch (e) {
      // Handle any errors
      print('Error retrieving user profile image URL: $e');
      return ''; // Return an empty string in case of errors
    }
  }

  void postMessage() async {
    try {
      if (textController.text.isNotEmpty) {
        String userProfileImageUrl =
            await getUserProfileImageUrl(currentUser.email!);

        String? img =
            _fileName != null ? await getUploadedFileUrl(_fileName!) : null;

        // Add the image URL to the post data if available
        Map<String, dynamic> postData = {
          'UserEmail': currentUser.email,
          'Message': textController.text,
          'Timestamp': Timestamp.now(),
          'Likes': [],
          'UserProfileImageUrl': userProfileImageUrl,
        };

        // Set the 'ImageUrl' field in postData based on the availability of the image URL
        if (img != null && img.isNotEmpty) {
          print('Image URL: $img');
          postData['ImageUrl'] = img;
        } else {
          postData['ImageUrl'] = '';
        }

        // Ensure img is awaited before assigning to postData
        // await the Future returned by getUploadedFileUrl
        // to get the actual string value
        await FirebaseFirestore.instance.collection("User Posts").add(postData);
        // Add the post data to the 'User Posts' collection

        // Clear text controller and reset _fileName
        setState(() {
          textController.clear();
          _fileName = null; // Reset _fileName after posting
        });

        print('Post data: $postData');
      }
    } catch (e) {
      print('Error posting message: $e');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4'],
    );

    if (result != null) {
      if (result.files.isNotEmpty) {
        setState(() {
          _fileBytes = result.files.first.bytes;
          // Extract filename from the full file path
          _fileName = result.files.first.name;
          // Ensure _fileName contains only the filename
          List<String> pathSegments = _fileName!.split('/');
          if (pathSegments.isNotEmpty) {
            _fileName = pathSegments.last;
          }
        });

        if (_fileBytes != null) {
          // Upload file
          await FirebaseStorage.instance
              .ref('uploads/$_fileName')
              .putData(_fileBytes!);

          // Get uploaded file URL
          String? fileUrl = await getUploadedFileUrl(_fileName!);
          if (fileUrl != null) {
            print('File URL: $fileUrl');
            // Here you can use the file URL as needed
          } else {
            print('Failed to get file URL.');
          }
        } else {
          print("File bytes are null.");
        }
      } else {
        print("No file selected.");
      }
    } else {
      // Reset _fileName to an empty string if file picker is canceled
      setState(() {
        _fileName = '';
      });
    }
  }

  Future<String?> getUploadedFileUrl(String fileName) async {
    try {
      // Get reference to the uploaded file
      final ref = FirebaseStorage.instance.ref('uploads/$fileName');

      // Get download URL
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      print('Error getting uploaded file URL: $e');
      return '';
    }
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProfilePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("     T H E \nU N S A I D"),
        centerTitle: true,
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signUserOut,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("Timestamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
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
                        final String _imageUrl = post['ImageUrl'];

                        return WallPost(
                          message: message,
                          user: user,
                          postID: postID,
                          likes: likes,
                          time: time,
                          userProfileImageUrl: userProfileImageUrl,
                          imageUrl: _imageUrl, // Pass the image URL to WallPost
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                        controller: textController,
                        hintText: 'care to rant?',
                        obscureText: false),
                  ),
                  IconButton(
                    onPressed: () {
                      _pickFile();
                    },
                    icon: Icon(Icons.image_search_outlined),
                  ),

                  // IconButton(
                  //   onPressed: () async {
                  //     FilePickerResult? result =
                  //         await FilePicker.platform.pickFiles(
                  //       type: FileType.custom,
                  //       allowedExtensions: ['jpg', 'png', 'jpeg'],
                  //     );

                  //     if (result != null) {
                  //       if (result.files.isNotEmpty) {
                  //         Uint8List? fileBytes = result.files.first.bytes;
                  //         String? fileName = result.files.first.name;

                  //         if (fileBytes != null && fileName != null) {
                  //           await FirebaseStorage.instance
                  //               .ref('uploads/$fileName')
                  //               .putData(fileBytes);
                  //           // File uploaded successfully
                  //         } else {
                  //           // Handle the case when either fileBytes or fileName is null
                  //           print('File bytes or file name is null.');
                  //         }
                  //       } else {
                  //         // Handle the case when no files are selected
                  //         print('No files selected.');
                  //       }
                  //     } else {
                  //       // Handle the case when FilePickerResult is null
                  //       print('File picker result is null.');
                  //     }
                  //   },
                  //   icon: Icon(Icons.upload),
                  // ),

                  IconButton(
                      onPressed: () {
                        postMessage();
                      },
                      icon: Icon(Icons.send))
                ],
              ),
            ),
            Text(currentUser.email.toString())
          ],
        ),
      ),
    );
  }
}
