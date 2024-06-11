// import 'package:cs_location_tracker_app/common/toast.dart';
// import 'package:cs_location_tracker_app/screens/welcome_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cs_location_tracker_app/screens/old_reports.dart';
import 'package:flutter/material.dart';

class LiveCases extends StatefulWidget {
  const LiveCases({super.key});

  @override
  State<LiveCases> createState() => _LiveCasesState();
}

class _LiveCasesState extends State<LiveCases> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (e) => const OldReports()));
            },
            child: const Icon(Icons.chat_rounded)),
        const SingleChildScrollView()
      ],
    );
  }
}

// ElevatedButton(
//         onPressed: () {
//           FirebaseAuth.instance.signOut();
//           showToast(message: 'Signed out');
//           Navigator.push(context, 
//                     MaterialPageRoute(
//                       builder: (e)=> const WelcomeScreen()));
//         },
//         child: const Text("Sign Out"));