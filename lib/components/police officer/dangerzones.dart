import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/local_notification_services.dart';
import 'live_location_service.dart';

class DangerZoneMapPage extends StatefulWidget {
  const DangerZoneMapPage({super.key});

  @override
  State<DangerZoneMapPage> createState() => _DangerZoneMapPageState();
}

class _DangerZoneMapPageState extends State<DangerZoneMapPage> {
  final LiveLocationService _liveLocationService = LiveLocationService();
  GoogleMapController? _mapController;
  Set<Circle> _dangerZoneCircles = {};
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? _lastDangerAlertTime;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadDangerZones();
    _startListeningToLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await _liveLocationService.getCurrentPosition();
      setState(() {});

      _updateCameraPosition();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error getting current location: $e');
    }
  }

  bool _isInDangerZone(Position position) {
    for (Circle dangerZone in _dangerZoneCircles) {
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        dangerZone.center.latitude,
        dangerZone.center.longitude,
      );
      if (distanceInMeters <= dangerZone.radius) {
        return true;
      }
    }
    return false;
  }

  void _startListeningToLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _updateCameraPosition();

      // Check if user is in a danger zone
      if (_isInDangerZone(position)) {
        _showNotification();
      }
    });
  }

  void _showNotification() {
    final now = DateTime.now();
    if (_lastDangerAlertTime == null ||
        now.difference(_lastDangerAlertTime!) > const Duration(minutes: 1)) {
      NotificationService.showInstantNotification(
          'Warning', "You are in a danger zone");
      _lastDangerAlertTime = now;
    }
  }

  void _updateCameraPosition() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  Future<void> _loadDangerZones() async {
    try {
      List<DangerZone> dangerZones =
          await _liveLocationService.getDangerZones();
      setState(() {
        _dangerZoneCircles = dangerZones
            .map((zone) => Circle(
                  circleId: CircleId(
                      'danger_zone_${zone.latitude}_${zone.longitude}'),
                  center: LatLng(zone.latitude, zone.longitude),
                  radius: zone.radius,
                  fillColor:
                      const Color.fromARGB(255, 251, 91, 80).withOpacity(0.3),
                  strokeColor: const Color.fromARGB(255, 248, 89, 78),
                  strokeWidth: 1,
                ))
            .toSet();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching danger zones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition != null
          ? GoogleMap(
              mapType: MapType.hybrid,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 17,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              circles: _dangerZoneCircles,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class DangerZone {
  final double latitude;
  final double longitude;
  final double radius;

  DangerZone({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });
}

extension on LiveLocationService {
  Future<List<DangerZone>> getDangerZones() async {
    // Implement the logic to fetch danger zones from Firestore
    // For example:
    final snapshot =
        await FirebaseFirestore.instance.collection('danger_zones').get();
    return snapshot.docs.map((doc) {
      return DangerZone(
        latitude: doc['latitude'],
        longitude: doc['longitude'],
        radius: doc['radius'],
      );
    }).toList();
  }
}
