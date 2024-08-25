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
      return LatLng(
        (data['location'] as GeoPoint).latitude,
        (data['location'] as GeoPoint).longitude,
      );
    });
  }

  Future<void> updateHelpRequestReadStatus(
      String trackingId, bool isRead) async {
    await _firestore.collection('help_requests').doc(trackingId).update({
      'isRead': isRead,
    });
  }

  Stream<List<HelpRequest>> getActiveHelpRequests() {
    return _firestore
        .collection('help_requests')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          final initialLocation = data['initialLocation'] as GeoPoint;
          final currentLocation = data['currentLocation'] as GeoPoint?;

          return HelpRequest(
            studentUid: data['studentUid'] as String,
            studentName: data['studentName'] as String,
            referenceNumber: data['referenceNumber'] as String,
            initialLocation: LatLng(
              initialLocation.latitude,
              initialLocation.longitude,
            ),
            currentLocation: currentLocation != null
                ? LatLng(
                    currentLocation.latitude,
                    currentLocation.longitude,
                  )
                : null,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            trackingId: data['trackingId'] as String,
            isRead: data['isRead'] ?? false, // Default value if not present
          );
        } catch (e) {
          print("Error parsing HelpRequest: $e");
          rethrow; // Rethrow or handle error as needed
        }
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
      final initialLocation = data['initialLocation'] as GeoPoint;
      final currentLocation = data['currentLocation'] as GeoPoint?;

      return HelpRequest(
        studentUid: data['studentUid'] as String,
        studentName: data['studentName'] as String,
        referenceNumber: data['referenceNumber'] as String,
        initialLocation: LatLng(
          initialLocation.latitude,
          initialLocation.longitude,
        ),
        currentLocation: currentLocation != null
            ? LatLng(
                currentLocation.latitude,
                currentLocation.longitude,
              )
            : null,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        trackingId: data['trackingId'] as String,
        isRead: data['isRead'] ?? false, // Default value if not present
      );
    });
  }

  Future<void> updatePoliceOfficerLocation(
      String officerId, Position position) async {
    await _firestore.collection('police_officers').doc(officerId).update({
      'location': GeoPoint(position.latitude, position.longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

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

  void startPeriodicLocationUpdates(String officerId,
      {Duration interval = const Duration(seconds: 3)}) {
    Stream.periodic(interval).listen((_) async {
      try {
        Position position = await getCurrentPosition();
        await updatePoliceOfficerLocation(officerId, position);
      } catch (e) {
        print("Error updating police officer location: $e");
      }
    });
  }

  Future<void> updateStudentLocation(
      String studentId, Position position) async {
    await _firestore.collection('help_requests').doc(studentId).update({
      'currentLocation': GeoPoint(position.latitude, position.longitude),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateHelpRequestStatus(String trackingId, String status) async {
    await _firestore.collection('help_requests').doc(trackingId).update({
      'status': status,
    });
  }

  Future<void> deleteHelpRequest(String trackingId) async {
    await _firestore.collection('help_requests').doc(trackingId).delete();
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
  final bool isRead;

  HelpRequest({
    required this.studentUid,
    required this.studentName,
    required this.referenceNumber,
    required this.initialLocation,
    this.currentLocation,
    required this.timestamp,
    required this.trackingId,
    required this.isRead,
  });

  factory HelpRequest.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final initialLocation = data['initialLocation'] as GeoPoint;
    final currentLocation = data['currentLocation'] as GeoPoint?;

    return HelpRequest(
      studentUid: data['studentUid'] as String,
      studentName: data['studentName'] as String,
      referenceNumber: data['referenceNumber'] as String,
      initialLocation:
          LatLng(initialLocation.latitude, initialLocation.longitude),
      currentLocation: currentLocation != null
          ? LatLng(currentLocation.latitude, currentLocation.longitude)
          : null,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      trackingId: data['trackingId'] as String,
      isRead: data['isRead'] ?? false,
    );
  }
}
