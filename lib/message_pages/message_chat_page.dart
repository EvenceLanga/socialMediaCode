//import 'package:chatapp_firebase/message_pages/components/chart_bubble.dart';
import 'package:chatapp_firebase/model/chart_services.dart';
import 'package:chatapp_firebase/pages/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageChatPage extends StatefulWidget {
  final String receiveuserName;
  final String receiveUserID;
  const MessageChatPage({
    super.key,
    required this.receiveUserID,
    required this.receiveuserName});

  @override
  State<MessageChatPage> createState() => _MessageChatPageState();
}

class _MessageChatPageState extends State<MessageChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChartService _chartService = ChartService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
  // Only send the message if there is something to send
  if (_messageController.text.isNotEmpty) {
    // Assuming you have a Firestore collection named 'chat_rooms'
    final CollectionReference messages = FirebaseFirestore.instance.collection('chat_rooms');

    // Create a new message document with the message, timestamp, and isRead fields
    final messageData = {
      "message": _messageController.text,
      "timestamp": Timestamp.now(), // Use Firestore's Timestamp to get the current time
      "isRead": false, // Set isRead to false initially
      "senderId": _firebaseAuth.currentUser!.uid, // You may want to include the sender's ID
    };

    // Add the message to the chat room document (you should replace 'chatRoomID' with the actual chat room ID)
    await messages
        .doc('chatRoomID')
        .collection('messages')
        .add(messageData);

    // Clear the message text controller after sending the message
    _messageController.clear();
  }
}

    @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.receiveuserName),
      ),
      body: Column(
        children: [
          //messages
          Expanded(child: _buildMessageList(),
          ),
          //user input
          _buildMessageInput(), 

          const SizedBox(height: 25)
        ],
      ),
    );
  }
   Widget _buildMessageList() {
  return StreamBuilder(
    stream: _chartService.getMessage(
      widget.receiveUserID,
      _firebaseAuth.currentUser!.uid,
    ),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error${snapshot.error}');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('loading..');
      }

      QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;

      return ListView(
        children: querySnapshot.docs.map((document) => _buildMessageItem(document)).toList(),
      );
    },
  );
}

Widget _buildMessageItem(DocumentSnapshot document) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  bool isSender = (data['senderId'] == _firebaseAuth.currentUser!.uid);
  var alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;
  var bubbleColor = isSender ? Colors.blue : Colors.grey; // Define colors based on sender or receiver

  Timestamp timestamp = data['timestamp']; // Assuming your Firestore field is named 'timestamp'
  DateTime dateTime = timestamp.toDate(); // Convert Firestore timestamp to DateTime

  return Container(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bubbleColor, // Use the bubbleColor based on sender or receiver
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  data['message'],
                  style: const TextStyle(
                    color: Colors.white, // Text color within the chat bubble
                  ),
                ),
                const SizedBox(height: 4), // Add some spacing between message and time
                Text(
                  '${dateTime.hour}:${dateTime.minute}', // Format and display the time
                  style: const TextStyle(
                    color: Colors.white70, // Text color for the time
                    fontSize: 12, // Adjust the font size as needed
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}



  // build message input
  Widget _buildMessageInput(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
      children: [
        //textfiels
        Expanded(child: MyTextField(
          controller: _messageController,
          hintText: 'Enter message',
          obscureText: false,
        )),
        //send button 
        IconButton(onPressed: sendMessage, icon: const Icon(Icons.send,size: 40,)),
      ],
    ));
  }
}