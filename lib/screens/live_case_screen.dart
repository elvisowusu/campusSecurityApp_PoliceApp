import 'package:cs_location_tracker_app/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LiveCases extends StatefulWidget {
  const LiveCases({super.key});

  @override
  State<LiveCases> createState() => _LiveCasesState();
}

class _LiveCasesState extends State<LiveCases> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.push(context, 
                    MaterialPageRoute(
                      builder: (e)=> const WelcomeScreen()));
        },
        child: const Text("Sign Out"));
  }
}
