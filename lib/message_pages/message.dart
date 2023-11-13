import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'message_chat_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  //instance auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Messages'),
      ),
      body: _buildUserList(),
    );
  }
  //build a list of users except the one logged in
  Widget _buildUserList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Text("Error");
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("Loading...");
      }
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          DocumentSnapshot document = snapshot.data!.docs[index];
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          if (_auth.currentUser!.uid != data['userName']) {
            // Determine the isRead status for the user's last message
            bool isRead = determineIsReadStatus(data['uid']);

            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(data['userName']),
              subtitle: _buildLastMessage(data['uid'], isRead), // Pass isRead status here
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => MessageChatPage(
                      receiveuserName: data['userName'],
                      receiveUserID: data['uid'],
                    )),
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        },
      );
    },
  );
}

bool determineIsReadStatus(String chatRoomID) {
  // Query your Firestore to determine the isRead status for the last message in the specified chat room
  // You need to implement the logic to retrieve this status based on your Firestore structure
  // Return true if the message is read, otherwise return false
  // You may need to implement a Firestore query to determine this status

  return true;
}


Widget _buildLastMessage(String chatRoomID, bool isRead) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        print("Error: ${snapshot.error}");
        return const Text("Error occurred");
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
         return const CircularProgressIndicator();
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Text("No messages yet", style: TextStyle(color: isRead ? Colors.black : Colors.blue));
      }
      DocumentSnapshot messageDoc = snapshot.data!.docs.first;
      Map<String, dynamic> messageData = messageDoc.data() as Map<String, dynamic>;
      String message = messageData['message'];

      // Check if the message is longer than 30 characters
      if (message.length > 30) {
        // Trim the message to the first 30 characters
        message = message.substring(0, 30);
      }

      // Change text color based on read status
      return Text(message, style: TextStyle(color: isRead ? Colors.black : Colors.blue));
    },
  );
}
}

