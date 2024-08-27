import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:security_app/components/police%20officer/emergency_notification.dart';
import 'package:timezone/timezone.dart' as tz;

import 'user_session.dart';

class NotificationService {
  // creating instance for firebaseMessaging to allow fcm
  static final _firebaseMessaging = FirebaseMessaging.instance;
  //creating an instance for the FlutterLocalNotification plugin
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // request notification permission
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    //get the device fcm token
    final token = await _firebaseMessaging.getToken();
    print("Device token: $token");
  }

  // Function to handle notification tap and navigate to MapArea
static Future<void> onDidReceiveNotification(
    NotificationResponse notificationResponse) async {
  // Check if the notification was tapped
  if (notificationResponse.notificationResponseType ==
      NotificationResponseType.selectedNotification) {
    // Retrieve policeOfficerId from session
    String? policeOfficerId = await UserSession.getPoliceOfficerId();

    // Check if policeOfficerId is null
    if (policeOfficerId != null) {
      // Navigate to Emergency notification screen
      Get.to(() => EmergencyNotifications(policeOfficerId: policeOfficerId));
    } else {
      // Handle case where policeOfficerId is not available
      Fluttertoast.showToast(msg: "Error: Police ID not found.");
    }
  }
}


  //initializing the local notification plugin
  static Future<void> localNotInit() async {
    //defining android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    //ios initialization settings
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    //combining android and ios initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    //initializing the plugin with the specified settings
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    //initializing notification permission for android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // method to show an instant notification when a button is clicked
  static Future<void> showInstantNotification(String title, String body) async {
    //now to notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails("channel_Id", "channel_Name",
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  // method to show a scheduled notification when a button is clicked
  static Future<void> showScheduledNotification(
      String title, String body, DateTime scheduledDate) async {
    //now to notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails("channel_Id", "channel_Name",
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.zonedSchedule(0, title, body,
        tz.TZDateTime.from(scheduledDate, tz.local), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }
}
