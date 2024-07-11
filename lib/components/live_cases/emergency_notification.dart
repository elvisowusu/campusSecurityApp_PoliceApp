import 'package:cs_location_tracker_app/components/live_cases/map_area.dart';
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
                    builder: (context) =>  const MapArea(),
                  ),
                );
              },
            );
          },
        ),
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
  Notification(
    contactName: 'John Doe',
    message: 'In Danger',
  ),
];
