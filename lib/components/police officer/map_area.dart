import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'live_location_service.dart';

class MapArea extends StatefulWidget {
  final HelpRequest helpRequest;

  const MapArea({super.key, required this.helpRequest});

  @override
  State<MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<MapArea> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final LiveLocationService _liveLocationService = LiveLocationService();
  late StreamSubscription<HelpRequest> _locationSubscription;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _locationSubscription = _liveLocationService
        .getHelpRequestUpdates(widget.helpRequest.trackingId)
        .listen((updatedHelpRequest) {
      _updateMarkers(updatedHelpRequest);
    });
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  void _updateMarkers(HelpRequest helpRequest) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('initial_${helpRequest.trackingId}'),
        position: helpRequest.initialLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Initial Location'),
      ));
      if (helpRequest.currentLocation != null) {
        _markers.add(Marker(
          markerId: MarkerId('current_${helpRequest.trackingId}'),
          position: helpRequest.currentLocation!,
          infoWindow: const InfoWindow(title: 'Current Location'),
        ));
        _updateCameraPosition(helpRequest.currentLocation!);
      }
    });
  }

  Future<void> _updateCameraPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 15),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking ${widget.helpRequest.studentName}'),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: widget.helpRequest.initialLocation,
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
      ),
    );
  }
}