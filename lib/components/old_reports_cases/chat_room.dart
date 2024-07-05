import 'package:cs_location_tracker_app/components/old_reports_cases/notifications.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Report Cases',
              style: TextStyle(letterSpacing: 1),
            ),
            elevation: 1,
            backgroundColor: Colors.blue,
            bottom: const TabBar(
                indicatorWeight: 2,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  Tab(text: 'CHAT'),
                  Tab(
                    text: 'Calls',
                  )
                ]),
          ),
          body: const TabBarView(
            children: [
              MainChatPage(),
            ])
        ));
  }
}
