import 'package:flutter/material.dart';

class MapArea extends StatelessWidget {
  const MapArea({super.key, required this.contact});
  final String contact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Tracking $contact's location..."),
    );
  }
}
