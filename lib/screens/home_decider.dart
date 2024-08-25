import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../components/counselor/notifications.dart';
import '../components/police officer/emergency_notification.dart';
import '../components/police officer/live_location_service.dart';
import '../components/police officer/map_area.dart';
import '../main.dart';
import 'splash_screen.dart';

class HomeDecider extends StatelessWidget {
  const HomeDecider({super.key});

  Future<Widget> getInitialScreen() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SplashScreen();
    }

    // Check user's role and navigate accordingly
    bool isPoliceOfficer = await _checkUserRole(user.uid, 'police_officers');
    bool isCounselor = await _checkUserRole(user.uid, 'counselors');

    if (isPoliceOfficer) {
            // Set up FCM for police officers
      _setupFCMForPoliceOfficer(user.uid);
      return EmergencyNotifications(policeOfficerId: user.uid);
    } else if (isCounselor) {
      return CounselorNotificationsPage();
    } else {
      return const SplashScreen(); // Default to SplashScreen if role is not found
    }
  }

  Future<bool> _checkUserRole(String uid, String collection) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(uid)
        .get();
    return userDoc.exists;
  }

    // Add this method to set up FCM for police officers
void _setupFCMForPoliceOfficer(String policeOfficerId) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      // Show a local notification
      showLocalNotification(message);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    if (message.data['trackingId'] != null) {
      // Navigate to MapArea with tracking ID
      navigateToMapArea(message.data['trackingId'], policeOfficerId);
    }
  });
}

void showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'emergency_channel',
    'Emergency Notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title ?? 'Emergency',
    message.notification?.body ?? 'A student needs help!',
    platformChannelSpecifics,
    payload: json.encode({
      'trackingId': message.data['trackingId'],
      'policeOfficerId': FirebaseAuth.instance.currentUser?.uid,
    }),
  );
}

void navigateToMapArea(String trackingId, String policeOfficerId) async {
  // Fetch the HelpRequest data from Firestore
  DocumentSnapshot helpRequestDoc = await FirebaseFirestore.instance
      .collection('help_requests')
      .doc(trackingId)
      .get();

  if (helpRequestDoc.exists) {
    HelpRequest helpRequest = HelpRequest.fromSnapshot(helpRequestDoc);

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => MapArea(
          helpRequest: helpRequest,
          policeOfficerId: policeOfficerId,
        ),
      ),
    );
  } else {
    print('Help request not found');
  }
}


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getInitialScreen(),
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildWidgetFromSnapshot(snapshot),
        );
      },
    );
  }

  Widget _buildWidgetFromSnapshot(AsyncSnapshot<Widget> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox.shrink(); // Invisible placeholder during loading
    }
    if (snapshot.hasError) {
      return const Center(child: Text('Error loading user data'));
    }
    if (snapshot.hasData) {
      return snapshot.data!;
    }
    return const SplashScreen(); // Default case
  }
}
