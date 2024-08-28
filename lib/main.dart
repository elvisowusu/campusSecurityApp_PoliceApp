import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:security_app/components/police%20officer/emergency_notification.dart';
import 'package:security_app/firebase_options.dart';
import 'package:security_app/screens/splash_screen.dart';
import 'package:security_app/services/local_notification_services.dart';
import 'package:security_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_decider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services/user_session.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// Function to listen to background messages
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print('something is received in the background');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initializing Firebase Messaging
  await NotificationService.init();

  // Initializing local notifications
  await NotificationService.localNotInit();

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // where to go after tapping a background message
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('background message tapped');
      navigatorKey.currentState!.pushNamed("/emergency", arguments: message);
    }
  });

  // now handling foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print('got a message in the foreground');
    if (message.notification != null) {
      NotificationService.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  // now handling terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print('launched from terminated state');
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed("/emergency", arguments: message);
    });
  }

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? policeOfficerId;

  @override
  void initState() {
    super.initState();
    _loadPoliceOfficerId();
  }

  Future<void> _loadPoliceOfficerId() async {
    // Retrieve the policeOfficerId from SharedPreferences
    policeOfficerId = await UserSession.getPoliceOfficerId();
    setState(() {}); // Trigger a rebuild after the ID is loaded
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: FirebaseAuth.instance.currentUser == null
          ? const SplashScreen()
          : const HomeDecider(),
      navigatorKey: navigatorKey,
      routes: {
        "/emergency": (context) => EmergencyNotifications(
            policeOfficerId: policeOfficerId ?? 'unknown_officer'),
      },
    );
  }
}
