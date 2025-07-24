// chat_inbox_screen.dart
import 'package:flutter/material.dart';

import 'chat_list_screen.dart';


class ChatInboxScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recentChats = [
    {
      'userId': 'user_2',
      'userName': 'Ali Khan',
      'lastMessage': 'Hello!',
      'lastMessageTime': DateTime.now(),
      'profilePic': 'https://i.pravatar.cc/150?img=1'
    },
    {
      'userId': 'user_3',
      'userName': 'Ayesha Ahmed',
      'lastMessage': 'How are you?',
      'lastMessageTime': DateTime.now().subtract(Duration(minutes: 10)),
      'profilePic': 'https://i.pravatar.cc/150?img=2'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: ListView.builder(
        itemCount: recentChats.length,
        itemBuilder: (context, index) {
          final chat = recentChats[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(chat['profilePic'])),
            title: Text(chat['userName']),
            subtitle: Text(chat['lastMessage']),
            trailing: Text(
              TimeOfDay.fromDateTime(chat['lastMessageTime']).format(context),
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: chat['userId'],
                    receiverName: chat['userName'],
                    receiverImage: chat['profilePic'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
