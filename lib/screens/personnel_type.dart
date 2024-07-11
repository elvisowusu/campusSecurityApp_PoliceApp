import 'package:cs_location_tracker_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Choose your Role'),
          GestureDetector(
            onTap: () {
              // Navigate to sign-up page with the selected role
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SignUpScreen(role: 'Police Officer'),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.blue,
              child: const Text('Police Officer'),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to sign-up page with the selected role
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(role: 'Counsellor'),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.blue,
              child: const Text('Counsellor'),
            ),
          ),
        ],
      ),
    );
  }
}
