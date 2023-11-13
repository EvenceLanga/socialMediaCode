import 'package:chatapp_firebase/pages/my_list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onMessageTap;
  final void Function()? onGroupTap;
  final void Function()? onSignOut;
  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onMessageTap,
    required this.onGroupTap,
    required this.onSignOut
    });

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      backgroundColor: const Color.fromARGB(255, 17, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(
            children: [
               //header
          const DrawerHeader(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 64,)),

              MyListTile(
                icon: Icons.home, 
                text: 'H O M E',
                onTap: () => Navigator.pop(context),),
              MyListTile(
                icon: Icons.person, 
                text: 'P R O F I L E',
                onTap: onProfileTap),
              MyListTile(
                icon: Icons.message, 
                text: 'M E S S A G E S',
                onTap: onMessageTap),
              MyListTile(
                icon: Icons.group, 
                text: 'G R O U P S',
                onTap: onGroupTap),
            ],

          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
              child: MyListTile(
                icon: Icons.logout, 
                text: 'L O G O U T',
                onTap: onSignOut),
            
            )
              
        ],
      ),

    );
  }
}