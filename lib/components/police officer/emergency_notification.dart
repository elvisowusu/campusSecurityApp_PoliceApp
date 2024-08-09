import 'dart:ui';

import 'package:cs_location_tracker_app/components/police%20officer/map_area.dart';
import 'package:flutter/material.dart';

import '../../widgets/signout.dart';
import 'live_location_service.dart';

class EmergencyNotifications extends StatelessWidget {
  final LiveLocationService _liveLocationService = LiveLocationService();
  final String policeOfficerId;

  EmergencyNotifications({super.key, required this.policeOfficerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Live Cases'),
          backgroundColor: Colors.black.withOpacity(0.2), // Semi-transparent background color
        elevation: 0, // Remove shadow to enhance the glass effect
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // Background color with transparency
              ),
            ),
          ),
        ),
        actions: const [
          SignOutButton()
          ],
        ),
      body: StreamBuilder<List<HelpRequest>>(
        stream: _liveLocationService.getActiveHelpRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No active help requests'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final helpRequest = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(helpRequest.studentName[0]),
                ),
                title: Text(helpRequest.studentName),
                subtitle: Text('Ref: ${helpRequest.referenceNumber} - Help me!'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapArea(helpRequest: helpRequest, policeOfficerId: policeOfficerId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}