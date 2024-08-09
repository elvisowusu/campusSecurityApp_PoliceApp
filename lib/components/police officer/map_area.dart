import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'live_location_service.dart';

class MapArea extends StatefulWidget {
  final HelpRequest helpRequest;
  final String policeOfficerId;
  const MapArea({super.key, required this.helpRequest, required this.policeOfficerId});

  @override
  State<MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<MapArea> {
  final Completer<GoogleMapController> _controller = Completer();
  final LiveLocationService _liveLocationService = LiveLocationService();
  late StreamSubscription _studentLocationSubscription;
  late StreamSubscription _policeLocationSubscription;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupLocationStreams();
  }

  void _setupLocationStreams() {
    // Student location stream
    _studentLocationSubscription = _liveLocationService
        .getHelpRequestUpdates(widget.helpRequest.trackingId)
        .listen((updatedHelpRequest) {
      _updateMarkers(updatedHelpRequest, isStudent: true);
    });

    // Police officer location stream
    _policeLocationSubscription = _liveLocationService
        .getPoliceOfficerLocation(widget.policeOfficerId)
        .listen((policeLocation) {
      _updateMarkers(policeLocation, isStudent: false);
    });
  }

  void _updateMarkers(dynamic locationData, {required bool isStudent}) {
    setState(() {
      if (isStudent) {
        // Update student marker
        _markers.removeWhere((marker) => marker.markerId.value == 'student');
        if (locationData.currentLocation != null) {
          _markers.add(Marker(
            markerId: const MarkerId('student'),
            position: locationData.currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: locationData.studentName),
          ));
        }
      } else {
        // Update police officer marker
        _markers.removeWhere((marker) => marker.markerId.value == 'police');
        _markers.add(Marker(
          markerId: const MarkerId('police'),
          position: locationData,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Police Officer'),
        ));
      }

      _updatePolyline();
      _updateCameraPosition();
    });
  }

  void _updatePolyline() {
    final studentMarker = _markers.firstWhere(
      (marker) => marker.markerId.value == 'student',
      orElse: () => null as Marker,
    );
    final policeMarker = _markers.firstWhere(
      (marker) => marker.markerId.value == 'police',
      orElse: () => null as Marker,
    );

    if (studentMarker != null && policeMarker != null) {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: const PolylineId('student_to_police'),
        color: Colors.green,
        width: 5,
        points: [studentMarker.position, policeMarker.position],
      ));
    }
  }

  Future<void> _updateCameraPosition() async {
    if (_markers.length < 2) return;

    final GoogleMapController controller = await _controller.future;
    final bounds = _calculateBounds(_markers);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double? minLat, maxLat, minLng, maxLng;
    for (final marker in markers) {
      if (minLat == null || marker.position.latitude < minLat) {
        minLat = marker.position.latitude;
      }
      if (maxLat == null || marker.position.latitude > maxLat) {
        maxLat = marker.position.latitude;
      }
      if (minLng == null || marker.position.longitude < minLng) {
        minLng = marker.position.longitude;
      }
      if (maxLng == null || marker.position.longitude > maxLng) {
        maxLng = marker.position.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  @override
  void dispose() {
    _studentLocationSubscription.cancel();
    _policeLocationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking ${widget.helpRequest.studentName}'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: widget.helpRequest.initialLocation,
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }
}

// Add this method to the LiveLocationService class
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