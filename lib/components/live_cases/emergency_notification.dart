import 'package:cs_location_tracker_app/components/old_reports_cases/chat_notifications.dart';
import 'package:cs_location_tracker_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';



class EmergencyNotifications extends StatefulWidget {
  const EmergencyNotifications({super.key});

  @override
  State<EmergencyNotifications> createState() => _EmergencyNotificationsState();
}


class _EmergencyNotificationsState extends State<EmergencyNotifications> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const  Text('Emergency notifications'),
        FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (e) => const ChatNotifications()));
            },
            
            child: const Icon(Icons.chat_rounded)
            ),
            FloatingActionButton(onPressed:() {
              Navigator.push(context,
                  MaterialPageRoute(builder: (e) => const WelcomeScreen()));},
              child:const Icon(Icons.chat_rounded),
             )
      ],
    );
  }
}