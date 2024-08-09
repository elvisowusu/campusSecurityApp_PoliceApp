import 'package:cs_location_tracker_app/components/police%20officer/emergency_notification.dart';
import 'package:cs_location_tracker_app/firebase_options.dart';
import 'package:cs_location_tracker_app/screens/splash_screen.dart';
import 'package:cs_location_tracker_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'components/counselor/notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: FirebaseAuth.instance.currentUser == null
          ? const SplashScreen()
          : const HomeDecider(),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading user data'));
        }
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return const SplashScreen(); // Default case
      },
    );
  }
}
