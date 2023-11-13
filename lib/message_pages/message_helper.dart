import 'package:cloud_firestore/cloud_firestore.dart';

bool determineIsReadStatus(String chatRoomID) {
  // Query your Firestore to determine the isRead status for the last message in the specified chat room
  // You may need to sort the messages by timestamp to get the latest one

  bool isRead = false; // Initialize with a default value

  // Example Firestore query
  FirebaseFirestore.instance
      .collection('chat_rooms')
      .doc(chatRoomID)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get()
      .then((querySnapshot) {
    if (querySnapshot.docs.isNotEmpty) {
      // Get the latest message
      final latestMessage = querySnapshot.docs.first;
      final messageData = latestMessage.data();

      // Check the isRead field from the latest message
      isRead = messageData['isRead'] ?? false;
    }
  }).catchError((error) {
    // Handle errors here, such as Firestore query errors
    print("Error: $error");
  });

  return isRead;
}
