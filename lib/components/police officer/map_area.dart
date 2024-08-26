import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'live_location_service.dart';

class MapArea extends StatefulWidget {
  final HelpRequest helpRequest;
  final String policeOfficerId;

  const MapArea(
      {super.key, required this.helpRequest, required this.policeOfficerId});

  @override
  State<MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<MapArea> {
  final Completer<GoogleMapController> _controller = Completer();
  final LiveLocationService _liveLocationService = LiveLocationService();
  late StreamSubscription _studentLocationSubscription;
  late StreamSubscription _policeLocationSubscription;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  int? _estimatedArrivalTime;

  @override
  void initState() {
    super.initState();
    _setupLocationStreams();
    _liveLocationService.startPeriodicLocationUpdates(widget.policeOfficerId);
  }

  void _setupLocationStreams() {
    _studentLocationSubscription = _liveLocationService
        .getHelpRequestUpdates(widget.helpRequest.trackingId)
        .listen(_updateStudentMarker);

    _policeLocationSubscription = _liveLocationService
        .getPoliceOfficerLocation(widget.policeOfficerId)
        .listen(_updatePoliceMarker);
  }

  void _updateStudentMarker(HelpRequest updatedHelpRequest) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'student');
      _markers.add(Marker(
        markerId: const MarkerId('student'),
        position: updatedHelpRequest.currentLocation ??
            updatedHelpRequest.initialLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: updatedHelpRequest.studentName),
      ));
      _updatePolylineAndCamera();
    });
  }

  void _updatePoliceMarker(LatLng policeLocation) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'police');
      _markers.add(Marker(
        markerId: const MarkerId('police'),
        position: policeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Police Officer'),
      ));
      _updatePolylineAndCamera();
    });
  }

  Future<void> _updatePolylineAndCamera() async {
    final studentMarker = _markers.firstWhere(
      (marker) => marker.markerId.value == 'student',
      orElse: () =>
          const Marker(markerId: MarkerId('student'), position: LatLng(0, 0)),
    );
    final policeMarker = _markers.firstWhere(
      (marker) => marker.markerId.value == 'police',
      orElse: () =>
          const Marker(markerId: MarkerId('police'), position: LatLng(0, 0)),
    );

    if (studentMarker.position.latitude == 0 ||
        policeMarker.position.latitude == 0) return;

    final routePoints = await _getRouteBetweenLocations(
      studentMarker.position,
      policeMarker.position,
    );

    if (routePoints.isNotEmpty) {
      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('student_to_police'),
          color: Colors.blue,
          width: 5,
          points: routePoints,
        ));
      });

      _updateEstimatedArrivalTime(
          studentMarker.position, policeMarker.position);
      _animateToShowBothMarkers();
    }
  }

  Future<List<LatLng>> _getRouteBetweenLocations(
      LatLng start, LatLng end) async {
    const apiKey = 'AIzaSyA9rrWyEgPUPc0LOkbLG6xiHY4S-AuoJs0';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final routes = data['routes'] as List<dynamic>;
      if (routes.isNotEmpty) {
        final points = routes[0]['overview_polyline']['points'] as String;
        return _decodePolyline(points);
      }
    }

    return [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(
        (lat / 1E5),
        (lng / 1E5),
      ));
    }

    return polyline;
  }

  void _updateEstimatedArrivalTime(LatLng start, LatLng end) {
    double distanceInMeters = Geolocator.distanceBetween(
        start.latitude, start.longitude, end.latitude, end.longitude);
    int estimatedMinutes =
        (distanceInMeters / 833.33).round(); // Assuming 50 km/h speed
    setState(() {
      _estimatedArrivalTime = estimatedMinutes;
    });
  }

  Future<void> _animateToShowBothMarkers() async {
    if (_markers.length < 2) return;

    final GoogleMapController controller = await _controller.future;
    final bounds = _calculateBounds(_markers);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    return LatLngBounds(
      southwest: LatLng(
        markers.map((m) => m.position.latitude).reduce(min),
        markers.map((m) => m.position.longitude).reduce(min),
      ),
      northeast: LatLng(
        markers.map((m) => m.position.latitude).reduce(max),
        markers.map((m) => m.position.longitude).reduce(max),
      ),
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
      body: Stack(
        children: [
          GoogleMap(
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
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          if (_estimatedArrivalTime != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: Text('ETA: $_estimatedArrivalTime min'),
              ),
            ),
        ],
      ),
    );
  }
}
