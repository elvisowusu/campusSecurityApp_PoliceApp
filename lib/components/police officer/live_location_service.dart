import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<LatLng> getPoliceOfficerLocation(String officerId) {
    return FirebaseFirestore.instance
        .collection('police_officers')
        .doc(officerId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      return LatLng(data['location'].latitude, data['location'].longitude);
    });
  }
  
  
  Stream<List<HelpRequest>> getActiveHelpRequests() {
    return _firestore
        .collection('help_requests')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return HelpRequest(
          studentUid: doc['studentUid'],
          studentName: doc['studentName'],
          referenceNumber: doc['referenceNumber'],
          initialLocation: LatLng(
            doc['initialLocation'].latitude,
            doc['initialLocation'].longitude,
          ),
          currentLocation: doc['currentLocation'] != null
              ? LatLng(
                  doc['currentLocation'].latitude,
                  doc['currentLocation'].longitude,
                )
              : null,
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          trackingId: doc['trackingId'],
        );
      }).toList();
    });
  }

  Stream<HelpRequest> getHelpRequestUpdates(String trackingId) {
    return _firestore
        .collection('help_requests')
        .doc(trackingId)
        .snapshots()
        .map((doc) {
      return HelpRequest(
        studentUid: doc['studentUid'],
        studentName: doc['studentName'],
        referenceNumber: doc['referenceNumber'],
        initialLocation: LatLng(
          doc['initialLocation'].latitude,
          doc['initialLocation'].longitude,
        ),
        currentLocation: doc['currentLocation'] != null
            ? LatLng(
                doc['currentLocation'].latitude,
                doc['currentLocation'].longitude,
              )
            : null,
        timestamp: (doc['timestamp'] as Timestamp).toDate(),
        trackingId: doc['trackingId'],
      );
    });
  }
}

class HelpRequest {
  final String studentUid;
  final String studentName;
  final String referenceNumber;
  final LatLng initialLocation;
  final LatLng? currentLocation;
  final DateTime timestamp;
  final String trackingId;

  HelpRequest({
    required this.studentUid,
    required this.studentName,
    required this.referenceNumber,
    required this.initialLocation,
    this.currentLocation,
    required this.timestamp,
    required this.trackingId,
  });
}