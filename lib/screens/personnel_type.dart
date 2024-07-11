import 'package:cs_location_tracker_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:cs_location_tracker_app/widgets/custom_scaffold.dart';
import 'dart:ui'; // Needed for the BackdropFilter and ImageFilter

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      image: 'assets/images/security.avif',
      customContainer: Column(
        children: [
          const Expanded(
            flex: 7,
            child: SizedBox(
              height: 18,
            ),
          ),
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 102, 101, 101).withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                        child: Column(
                          children: [
                            const Text(
                              'Choose your Role',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 208, 219, 227),
                              ),
                            ),
                            const SizedBox(height: 30),
                            GestureDetector(
                              onTap: () {
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
                                  color: const Color.fromARGB(255, 181, 204, 223),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Police Officer",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 8, 8, 8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SignUpScreen(role: 'Counsellor'),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 181, 204, 223),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Counsellor",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 8, 8, 8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
