import 'package:cs_location_tracker_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:cs_location_tracker_app/widgets/custom_scaffold.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      customContainer: Column(
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
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Police Officer",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5.0,
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
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Counsellor ",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
