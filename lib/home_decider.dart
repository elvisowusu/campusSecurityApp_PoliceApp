import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:security_app/components/Counselor/notifications.dart';
import 'package:security_app/components/police%20officer/police_screen.dart';
import 'package:security_app/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      return const PoliceScreen();
    } else if (isCounselor) {
      return CounselorNotificationsPage();
    } else {
      return const SplashScreen();
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
