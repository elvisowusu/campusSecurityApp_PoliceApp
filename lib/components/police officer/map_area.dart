import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'live_location_service.dart';

class MapArea extends StatefulWidget {
  final LiveLocation liveLocation;

  const MapArea({Key? key, required this.liveLocation}) : super(key: key);

  @override
  State<MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends State<MapArea> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final LiveLocationService _liveLocationService = LiveLocationService();
  late StreamSubscription<List<LiveLocation>> _locationSubscription;

  @override
  void initState() {
    super.initState();
    _locationSubscription = _liveLocationService.getLiveLocations().listen((locations) {
      final updatedLocation = locations.firstWhere(
        (loc) => loc.trackingId == widget.liveLocation.trackingId,
        orElse: () => widget.liveLocation,
      );
      _updateCameraPosition(updatedLocation.location);
    });
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
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
        title: Text('Tracking ${widget.liveLocation.studentName}'),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: widget.liveLocation.location,
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
            markerId: MarkerId(widget.liveLocation.trackingId),
            position: widget.liveLocation.location,
            infoWindow: InfoWindow(title: widget.liveLocation.studentName),
          ),
        },
      ),
    );
  }
}