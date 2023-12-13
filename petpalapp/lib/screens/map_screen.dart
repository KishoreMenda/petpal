import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

String address = '';

//Used chatgpt and flutter documentation for bulding this class
class MapScreen extends StatefulWidget {
  late final LatLng? initialLocation;
  MapScreen({Key? key, this.initialLocation}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng selectedLocation = LatLng(0, 0);
  GoogleMapController? _controller;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation ?? LatLng(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location on Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(selectedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedLocation,
          zoom: 16.0,
        ),
        onMapCreated: (controller) {
          _controller = controller;
        },
        onTap: (LatLng position) {
          setState(() {
            selectedLocation = position;
          });
          markers = {Marker(markerId: MarkerId('selected'), position: position)};
          _controller?.animateCamera(CameraUpdate.newLatLng(position));
        },
        markers: markers,
      ),
    );
  }
}
