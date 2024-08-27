import 'package:cs_location_tracker_app/components/police%20officer/emergency_notification.dart';
import 'package:cs_location_tracker_app/firebase_options.dart';
import 'package:cs_location_tracker_app/screens/splash_screen.dart';
import 'package:cs_location_tracker_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_decider.dart';
import 'package:timezone/data/latest.dart' as tz;

final navigatorKey = GlobalKey<NavigatorState>();

//function to listen to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print('something is received at the background');
  }
}


// Add this function to handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    //initializing firebase messaging
  await NotificationService.init();

  //initializing local notification
  await NotificationService.localNotInit();

  // listen to background notification
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, 
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: FirebaseAuth.instance.currentUser == null
          ? const SplashScreen()
          : const HomeDecider(),
          navigatorKey: navigatorKey,
    );
  }
}

