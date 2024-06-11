import 'package:cs_location_tracker_app/components/old_reports_cases/chat_room.dart';
import 'package:flutter/material.dart';

class ChatNotifications extends StatefulWidget {
  const ChatNotifications({super.key});

  @override
  State<ChatNotifications> createState() => _ChatNotificationsState();
}

class _ChatNotificationsState extends State<ChatNotifications> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Old Cases'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (e) => const ChatRoom()));
              },
              child: const Text('chat room'),
            )
          ],
        ),
      ),
    );
  }
}
