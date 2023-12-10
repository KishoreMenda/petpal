import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

String address = '';

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
    // Use the initialLocation if provided, otherwise use default (0, 0)
    selectedLocation = widget.initialLocation ?? LatLng(0, 0);
    // Initialize the address when the screen is created
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
              // Return the selected location to the previous screen
              Navigator.of(context).pop(selectedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedLocation, // Initial map position
          zoom: 16.0,
        ),
        onMapCreated: (controller) {
          _controller = controller;
        },
        onTap: (LatLng position) {
          setState(() {
            selectedLocation = position;
          });
          // Clear existing markers and add a new one
          markers = {
            Marker(markerId: MarkerId('selected'), position: position)
          };
          _controller?.animateCamera(CameraUpdate.newLatLng(position));
          // var ad = reverseGeocode(position.latitude, position.longitude, "AIzaSyD-VBmD1uCO73BlnfOkIBZQeEhjaUJ-YS8");
          // setState(() {
          //   address = ad as String;
          // });
        },
        markers: markers,
      ),
    );
  }
}
