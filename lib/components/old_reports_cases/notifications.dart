import 'package:cs_location_tracker_app/components/old_reports_cases/individual_chat_room.dart';
import 'package:flutter/material.dart';

class MainChatPage extends StatelessWidget {
  const MainChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(notification.contactName[0]),
            ),
            title: Text(notification.contactName),
            subtitle: Text(notification.message),
            onTap: () {
              // Navigate to individual chat room
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndividualChatPage(contact: notification.contactName),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



class Notification {
  final String contactName;
  final String message;

  Notification({required this.contactName, required this.message});
}

List<Notification> notifications = [
  Notification(contactName: 'John Doe', message: 'Hello!', ),
  Notification(contactName: 'Jane Smith', message: 'How are you?'),
  Notification(contactName: 'Alice Johnson', message: 'Are you free today?'),
];