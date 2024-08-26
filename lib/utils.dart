// lib/utils.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cs_location_tracker_app/components/police officer/map_area.dart';
import 'package:cs_location_tracker_app/components/police officer/live_location_service.dart';

import 'main.dart'; // Update this import path as needed


void navigateToMapArea(String trackingId, String policeOfficerId) async {
  try {
    DocumentSnapshot helpRequestDoc = await FirebaseFirestore.instance
        .collection('help_requests')
        .doc(trackingId)
        .get();

    if (helpRequestDoc.exists) {
      HelpRequest helpRequest = HelpRequest.fromSnapshot(helpRequestDoc);

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => MapArea(
            helpRequest: helpRequest,
            policeOfficerId: policeOfficerId,
          ),
        ),
      );
    } else {
      print('Help request not found');
    }
  } catch (e) {
    print('Error navigating to MapArea: $e');
  }
}