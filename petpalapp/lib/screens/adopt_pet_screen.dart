import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petpalapp/view_model/pet_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:convert/convert.dart';
import 'package:url_launcher/url_launcher.dart';

class AdoptPetScreen extends StatefulWidget {
  final Pet pet;

  AdoptPetScreen({required this.pet});

  @override
  _AdoptPetScreenState createState() => _AdoptPetScreenState();
}

class _AdoptPetScreenState extends State<AdoptPetScreen> {
  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Widget _buildInfoCard(String label, String info) {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: 100.0,
      decoration: BoxDecoration(
        color: Color(0xFFF8F2F7),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            info,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> reverseGeocode(double lat, double lon, String apiKey) async {
    final baseUrl = 'maps.googleapis.com';
    final path = '/maps/api/geocode/json';
    final params = {
      'latlng': '$lat,$lon',
      'key': apiKey,
    };

    final uri = Uri.https(baseUrl, path, params);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['results'] != null) {
        // Extract the formatted address from the first result
        final formattedAddress = data['results'][0]['formatted_address'];
        return formattedAddress;
      }
    }

    return 'Reverse geocoding failed';
  }

  Future<void> _openMaps() async {
    final lat = double.parse(widget.pet.latit);
    final lon = double.parse(widget.pet.longit);

    // Check the platform
    if (Platform.isIOS) {
      // iOS
      final url = Uri.parse('https://maps.apple.com/?q=$lat,$lon');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        print('Could not launch $url');
      }
    } else if (Platform.isAndroid) {
      // Android
      final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        print('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFF5EDE2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Hero(
                    tag: widget.pet.id,
                    child: Container(
                      width: double.infinity,
                      height: 350.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              (widget.pet.imageUrl.contains("firebasestorage"))
                                  ? NetworkImage(widget.pet.imageUrl.toString())
                                  : const AssetImage('images/lab.png')
                                      as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40.0, left: 10.0),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.pet.name,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_border),
                      iconSize: 30.0,
                      color: Theme.of(context).primaryColor,
                      onPressed: () => print('Favorite ${widget.pet.name}'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  widget.pet.description,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                height: 120.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    SizedBox(width: 30.0),
                    _buildInfoCard('Age', widget.pet.age.toString()),
                    _buildInfoCard('Sex', widget.pet.sex),
                    _buildInfoCard('Color', widget.pet.color),
                    _buildInfoCard('ID', widget.pet.id.toString()),
                  ],
                ),
              ),
              ListTile(
                  title: const Text('Location'),
                  subtitle: SizedBox(
                    height: 150,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse(widget.pet.latit),
                            double.parse(widget.pet.longit)),
                        zoom: 15.0,
                      ),
                      markers: <Marker>{
                        Marker(
                          markerId: MarkerId(widget.pet.name),
                          position: LatLng(double.parse(widget.pet.latit),
                              double.parse(widget.pet.longit)),
                          infoWindow: InfoWindow(title: widget.pet.name),
                        ),
                      },
                    ),
                  )),
              Container(
                padding: EdgeInsets.all(16.0),
                child: FutureBuilder<String>(
                    future: reverseGeocode(
                        double.parse(widget.pet.latit),
                        double.parse(widget.pet.longit),
                        "AIzaSyD-VBmD1uCO73BlnfOkIBZQeEhjaUJ-YS8"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Street Address:',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            snapshot.data ?? 'No address available',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ],
                      );
                    }),
              ),
              ElevatedButton(
                  onPressed: _openMaps, child: const Text("Open on Maps")),
              Container(
                margin: EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
                width: double.infinity,
                height: 90.0,
                decoration: BoxDecoration(
                  color: Color(0xFFFFF2D0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  leading: CircleAvatar(
                    child: ClipOval(
                      child: Image(
                        height: 40.0,
                        width: 40.0,
                        image: AssetImage(owner.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    owner.name,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Owner',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  trailing: Text(
                    '1.68 km',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 25.0),
                child: Text(
                  owner.bio,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15.0,
                    height: 1.5,
                  ),
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
