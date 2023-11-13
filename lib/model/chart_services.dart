import 'package:chatapp_firebase/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChartService extends ChangeNotifier{
  //get instance of the auth and firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //send message
  Future<void> sendMessage(String receiverId, String message)async {
    //get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      message: message, 
      senderEmail: currentUserEmail,
      senderId: currentUserId, 
      timestamp: timestamp, 
      receiverId: receiverId);

    //construct chat room id from current user id and receiver id 
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // add new message to database
    await  _firestore
    .collection('chat_rooms')
    .doc(chatRoomId)
    .collection('messages')
    .add(newMessage.toMap());
  }
  // Get messages from the firebase
  Stream<QuerySnapshot> getMessage(String userId, String otherUseId){
    List<String> ids =[userId, otherUseId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
    .collection('chat_rooms')
    .doc(chatRoomId)
    .collection('messages')
    .orderBy('timestamp', descending: false)
    .snapshots();
  }
}