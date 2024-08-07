import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<LiveLocation>> getLiveLocations() {
    return _firestore
        .collection('live_locations')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LiveLocation(
          studentUid: doc['studentUid'],
          studentName: doc['studentName'],
          location: LatLng(
            doc['location'].latitude,
            doc['location'].longitude,
          ),
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          trackingId: doc['trackingId'],
        );
      }).toList();
    });
  }
}

class LiveLocation {
  final String studentUid;
  final String studentName;
  final LatLng location;
  final DateTime timestamp;
  final String trackingId;

  LiveLocation({
    required this.studentUid,
    required this.studentName,
    required this.location,
    required this.timestamp,
    required this.trackingId,
  });
}