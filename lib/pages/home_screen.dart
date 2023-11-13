import 'package:chatapp_firebase/helper/helper_method.dart';
import 'package:chatapp_firebase/message_pages/message.dart';
import 'package:chatapp_firebase/pages/group_page.dart';
import 'package:chatapp_firebase/pages/notification.dart';
import 'package:chatapp_firebase/pages/profile_page.dart';
import 'package:chatapp_firebase/pages/text_field.dart';
import 'package:chatapp_firebase/pages/wall_post.dart';
import 'package:chatapp_firebase/service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../profile_page/edit_profile.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  final AuthService authService = AuthService();
  String userName = "";
  String email = "";

  // Sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      // Store in Firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'email': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
      setState(() {
        textController.clear();
      });
    }
  }

  // Navigate to profile page
  void goToProfilePage() {
    Navigator.pop(context);

    // Replace these placeholder values with the actual user's information
  

    // Go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  const Notifications(),
      ),
    );
  }
  // Navigate to messages page
  void goToMessages() {
  Navigator.pop(context);
  // Go to messages page and pass the required arguments
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MessagePage(),
    ),
  );
}
  // Navigate to notification page
  void goToGroup() {
    Navigator.pop(context);

    // Go to notification page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GroupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[20],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Posts"),
        centerTitle: true,
          actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Handle home icon action
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search icon action
            },
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // Handle message icon action
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications icon action
            },
          ),
        ],
        
      ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(userName), // Replace with the actual user name
                accountEmail: Text(email), // Replace with the actual user email
                currentAccountPicture: const CircleAvatar(
                  radius: 65,
                  backgroundImage: NetworkImage(
                      'https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-image-182145777.jpg'),
                ),
                
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
                selectedColor: Theme.of(context).primaryColor,
                selected: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.home),
                title: const Text(
                  "H O M E",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GroupPage(),
                    ),
                  );
                },
                selectedColor: Theme.of(context).primaryColor,
                selected: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.group),
                title: const Text(
                  "G R O U P S",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  nextScreenReplace(
                    context,
                    const ProfilePage(),
                  );
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.group),
                title: const Text(
                  "P R O F I L E",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MessagePage(),
                    ),
                  );
                },
                selectedColor: Theme.of(context).primaryColor,
                selected: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.message),
                title: const Text(
                  "M E S S A G E S",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    )); // Close the drawer
                },
                selectedColor: Theme.of(context).primaryColor,
                selected: false,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.settings),
                title: const Text(
                  "S E T T I N G S",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () async {
                  Navigator.pop(context); // Close the drawer
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("L O G O U T"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.exit_to_app),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),

      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: (snapshot.data as QuerySnapshot).docs.length,
                      itemBuilder: (context, index) {
                      final post = (snapshot.data as QuerySnapshot).docs[index];
                       return WallPost(
                          Message: post["Message"],
                          user: post["email"],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
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
                      hintText: "Write something on the wall...",
                      obscureText: false,
                    ),
                  ),
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(Icons.arrow_circle_up),
                  ),
                ],
              ),
            ),
            Text(
              "Logged in as: ${currentUser.email}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
