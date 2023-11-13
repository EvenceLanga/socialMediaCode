import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../helper/helper_method.dart';
import 'buttons/comment_button.dart';
import 'buttons/delete_button.dart';
import 'buttons/like_button.dart';

class WallPost extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String Message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;
  
  const WallPost( {
    super.key,
    // ignore: non_constant_identifier_names
    required this.Message,
    required this.user,
    required this.time, 
    required this.postId,
    required this.likes,
    });

  @override
  State<WallPost> createState() => _WallPostState();
}
bool areCommentsVisible = false;

final Logger _logger = Logger();

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _commentTextController = TextEditingController();
  bool isLiked = false;

  @override
  void initState(){
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }
  void toggleLike(){
    setState(() {
      isLiked = !isLiked;
    });
    //Access the document in Firebase
    DocumentReference postRef = FirebaseFirestore.instance.collection("User Posts").doc(widget.postId);
    if(isLiked){
      //if the post is liked, add the user email to the "Likes" field
          postRef.update({
              "Likes": FieldValue.arrayUnion([currentUser.email])
            });
          }
          else{
            //if the post is unliked, remove the user's email from the "Like" field
            postRef.update({
              "Likes": FieldValue.arrayRemove([currentUser.email])
            });
          }
  }
  //add a comment
  void addComment(String commentText) {
  // Write the comment to Firebase under the comments collection for this post
  FirebaseFirestore.instance
      .collection("User Posts")
      .doc(widget.postId)
      .collection("Comment")
      .add({
        "CommentText": commentText,
        "CommentedBy": currentUser.email,
        "CommentTimestamp": FieldValue.serverTimestamp(),
      })
      .then((docRef) {
        _logger.d("Comment added with ID: ${docRef.id}");
      })
      .catchError((error) {
        _logger.d("Error adding comment: $error");
      });
}

  void showCommentDialog(){
    showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "write a comment.."),
        ),
        actions: [
          
          //cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              //clear controller
              _commentTextController.clear();
            }, 
            child: const Text("Cancel")),
            //post button
          TextButton(
            onPressed: (){
               addComment(_commentTextController.text);
               _commentTextController.clear();
            },
            child: const Text("Post")),
        ],
      ) );
  }
  //delete a post
  void deletePost(){
    // show a dialog box for confirmation before deleting the posts
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this po?"),
        actions: [
          //Cancel button
          TextButton(onPressed: () => Navigator.pop(context),
           child: const Text("Cancel")),
           //Delete button
           TextButton(
            onPressed: () async{
              //delete the comment in firebase
              final commentDocs = await FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .collection("Comment")
              .get();

              for (var doc in commentDocs.docs){
                await FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comment")
                .doc(doc.id)
                .delete();
              }
              //then delete the post
              FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .delete()
              .then((value) => print("post deleted"))
              .catchError((error) => print("failed to delete post:$error"));

              //dismiss the dialog box+
              Navigator.pop(context);
            },
           child: const Text("Delete"))
        ],
      ));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25,right: 25),
      padding:const EdgeInsets.all(25),
     
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          //message and user email
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
           children: [ 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                children: [
                  Text(widget.user,
                  style: TextStyle(color: Colors.grey[400]),
                  ),
                  
                Text(".",
                  style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(widget.time)
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.Message),
          ],
        ),
        //delete buttom
        if (widget.user == currentUser.email)
            DeleteButtom(onTap: deletePost),

           ]
          ),
        const SizedBox(width: 20, height: 30,),
        //buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            // likes
            Column(
              children: [
                LikeButton(
                  isLiked: isLiked, 
                  onTap: toggleLike),
            const SizedBox(height: 5),
            //likes count
            Text(
              widget.likes.length.toString(),
              style: const TextStyle(color: Colors.grey),
              ),
            
          ],
        ),

          // Comments
            Column(
              children: [
                //comment button
                CommentButton(onTap: showCommentDialog),
            const SizedBox(height: 5),
            //comment count
           const Text(
              '0',
              style: TextStyle(color: Colors.grey),
              ),
            
          ],
        )
          ],
        ),
        const SizedBox(height: 20),
        //comments under post
     // Update the StreamBuilder that renders 
     IconButton(
            icon: Icon(
              areCommentsVisible ? Icons.comment : Icons.comment_outlined,
            ),
            onPressed: () {
              setState(() {
                areCommentsVisible = !areCommentsVisible;
              });
            },
          ),

     Visibility(
          visible: areCommentsVisible,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comment")
                .orderBy("CommentTimestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // Show loading circle if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Set the background color to grey[300]
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    final commentData = doc.data() as Map<String, dynamic>;

                    return Comment(
                      text: commentData["CommentText"],
                      user: commentData["CommentedBy"],
                      time: formatDate(commentData["CommentTimestamp"]),
                    );
                  }).toList(),
                ),
              );
            },
          
  ))
      ],
      )
    );
  }
}
class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;

  const Comment({super.key, 
    required this.text,
    required this.user,
    required this.time,
  });
 @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      subtitle: Text("By: $user • $time"),
    );
  }
}