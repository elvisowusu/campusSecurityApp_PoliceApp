import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<LatLng> getPoliceOfficerLocation(String officerId) {
    return _firestore
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
      final data = doc.data() as Map<String, dynamic>;
      return HelpRequest(
        studentUid: data['studentUid'],
        studentName: data['studentName'],
        referenceNumber: data['referenceNumber'],
        initialLocation: LatLng(
          data['initialLocation'].latitude,
          data['initialLocation'].longitude,
        ),
        currentLocation: data['currentLocation'] != null
            ? LatLng(
                data['currentLocation'].latitude,
                data['currentLocation'].longitude,
              )
            : null,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        trackingId: data['trackingId'],
      );
    });
  }

  // New method to update police officer location
  Future<void> updatePoliceOfficerLocation(String officerId, Position position) async {
    await _firestore.collection('police_officers').doc(officerId).update({
      'location': GeoPoint(position.latitude, position.longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // New method to get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  // New method to start periodic location updates
  void startPeriodicLocationUpdates(String officerId, {Duration interval = const Duration(seconds: 3)}) {
    Stream.periodic(interval).listen((_) async {
      try {
        Position position = await getCurrentPosition();
        await updatePoliceOfficerLocation(officerId, position);
      } catch (e) {
        print("Error updating police officer location: $e");
      }
    });
  }
  Future<void> updateStudentLocation(String studentId, Position position) async {
  await _firestore.collection('help_requests').doc(studentId).update({
    'currentLocation': GeoPoint(position.latitude, position.longitude),
    'lastUpdated': FieldValue.serverTimestamp(),
  });
}

  // New method to update help request status
  Future<void> updateHelpRequestStatus(String trackingId, String status) async {
    await _firestore.collection('help_requests').doc(trackingId).update({
      'status': status,
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