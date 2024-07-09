import 'package:flutter/material.dart';

class PersonnelTypeScreen extends StatelessWidget {
  const PersonnelTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Personnel Type'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle police selection
              },
              child: const Text('Police'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle counselor selection
              },
              child: const Text('Counselor'),
            ),
          ],
        ),
      ),
    );
  }
}