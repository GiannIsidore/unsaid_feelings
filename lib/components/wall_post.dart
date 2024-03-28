import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:unsaid_feelings/components/comment_button.dart';
import 'package:unsaid_feelings/components/comments.dart';
import 'package:unsaid_feelings/components/delete_button.dart';
import 'package:unsaid_feelings/components/like_button.dart';
import 'package:unsaid_feelings/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postID;
  final List<String> likes;
  final String userProfileImageUrl;
  final String? imageUrl;
// add imageUrl
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postID,
    required this.likes,
    required this.time,
    required this.userProfileImageUrl,
    this.imageUrl,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  TextEditingController _comment = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postID);
    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postID)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: _comment,
          decoration: InputDecoration(hintText: "write a comment..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              addComment(_comment.text);
              Navigator.pop(context);
              _comment.clear();
            },
            child: Text("Post"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _comment.clear();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Deleting post..."),
        content: Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
            ),
          ),
          TextButton(
            onPressed: () async {
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postID)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postID)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postID)
                  .delete()
                  .then(
                    (value) => print("deleted"),
                  )
                  .catchError(
                    (error) => print("failed to delete"),
                  );

              Navigator.pop(context);
            },
            child: Text(
              "Delete",
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(
        top: 25,
        left: 25,
        right: 25,
      ),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.userProfileImageUrl),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Text(widget.time, style: TextStyle(color: Colors.grey[500])),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                      width: 200,
                      child: Text(
                        widget.message,
                        softWrap: true,
                      )),
                  if (widget.imageUrl!.isNotEmpty)
                    Image.network(
                      widget.imageUrl!,
                      width: 150, // Set width as needed
                      height: 150, // Set height as needed
                      fit: BoxFit.cover, // Adjust fit as needed
                    ),
                  SizedBox(
                    height: 7,
                  ),
                ],
              ),
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 45.0),
            child: Row(
              children: [
                Row(
                  children: [
                    LikeButton(isLiked: isLiked, onTap: toggleLike),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      widget.likes.length.toString(),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Row(
                  children: [
                    CommentButton(onTap: showCommentDialog),
                    SizedBox(
                      height: 3,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postID)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;
                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
