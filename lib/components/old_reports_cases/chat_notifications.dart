import 'package:flutter/material.dart';

class ChatNotifications extends StatefulWidget {
  const ChatNotifications({super.key});

  @override
  State<ChatNotifications> createState() => _ChatNotificationsState();
}

class _ChatNotificationsState extends State<ChatNotifications> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      child: const  Text('chat notifications'),
    );
  }
}