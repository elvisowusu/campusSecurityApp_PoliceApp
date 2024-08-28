import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:security_app/main.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // creating instance for firebaseMessaging to allow fcm
  static final _firebaseMessaging = FirebaseMessaging.instance;
    // Fetch the FCM token
  static Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }
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
      onDidReceiveNotificationResponse: onTapNotification,
      onDidReceiveBackgroundNotificationResponse: onTapNotification,
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

  // on tap local notification in foreground
  static void onTapNotification(NotificationResponse notificationResponse) {
    navigatorKey.currentState!
        .pushNamed("/emergency", arguments: notificationResponse);
  }

  // show simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id ', 'Emergency',
            channelDescription: 'student in Danger',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails);
  }
}
