import 'dart:ui';

import 'package:cs_location_tracker_app/widgets/signout.dart';
import 'package:flutter/material.dart';
import 'live_location_service.dart';
import 'map_area.dart';

class EmergencyNotifications extends StatelessWidget {
  final LiveLocationService _liveLocationService = LiveLocationService();

  EmergencyNotifications({super.key});

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
      body: StreamBuilder<List<LiveLocation>>(
        stream: _liveLocationService.getLiveLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No live locations available'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final liveLocation = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(liveLocation.studentName[0]),
                ),
                title: Text(liveLocation.studentName),
                subtitle: Text('Last updated: ${liveLocation.timestamp}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapArea(liveLocation: liveLocation),
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