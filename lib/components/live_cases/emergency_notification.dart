import 'package:cs_location_tracker_app/components/old_reports_cases/chat_notifications.dart';
import 'package:flutter/material.dart';

class EmergencyNotifications extends StatefulWidget {
  const EmergencyNotifications({super.key});

  @override
  State<EmergencyNotifications> createState() => _EmergencyNotificationsState();
}

class _EmergencyNotificationsState extends State<EmergencyNotifications> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Live Cases'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        floatingActionButton:  FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (e) => const ChatNotifications()));
            }, 
            tooltip: 'Old Cases',
            child: const Icon(Icons.chat_rounded)
            ),
      ),
    );
  }
}
