import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:security_app/components/police%20officer/emergency_notification.dart';
import 'package:security_app/firebase_options.dart';
import 'package:security_app/screens/splash_screen.dart';
import 'package:security_app/services/background_services.dart';
import 'package:security_app/services/local_notification_services.dart';
import 'package:security_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'components/police officer/dangerzones.dart';
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
    // Initialize and start the background service
  await initializeService();

  // Initializing Firebase Messaging
  await NotificationService.init();

  // Initializing local notifications
  await NotificationService.localNotInit();
  // Update FCM token
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    updateFcmToken(fcmToken);
  });

  // Get the initial token
  String? initialToken = await FirebaseMessaging.instance.getToken();
  if (initialToken != null) {
    updateFcmToken(initialToken);
  }

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // Handle notification when app is in background and user taps on it
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState?.pushNamed("/emergency");
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

  // Handle notification when app is terminated and opened from notification
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    Future.delayed(const Duration(minutes: 5), () {
      navigatorKey.currentState?.pushNamed("/emergency");
    });
  }

  // Run the app
  runApp(const MyApp());
}

Future<void> updateFcmToken(String token) async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    await FirebaseFirestore.instance
        .collection('police_officers')
        .doc(userId)
        .update({'fcmToken': token});
  }
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
        "/danger_zones": (context) => const DangerZoneMapPage(),
      },
    );
  }
}
