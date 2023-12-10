import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:petpalapp/screens/add_pet_screen.dart';
import 'package:petpalapp/screens/home_screen.dart';
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
  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MyHomePage(),
          ));
          break;
        }

      case 1:
        {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AddPetScreen(),
          ));
          break;
        }

      default:
        {}
    }
  }

  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Widget getWidget(String label, String info) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Color(0xFFF8F2F7),
        borderRadius: BorderRadius.circular(20.0),
      ),
      width: 80.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.amber[800],
            ),
          ),
          SizedBox(height: 8.0),
          Text(info),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EDE2),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        thickness: 5,
        child: SingleChildScrollView(
          child: Container(
            color: Color(0xFFF5EDE2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 350.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              (widget.pet.imageUrl.contains("firebasestorage"))
                                  ? NetworkImage(widget.pet.imageUrl.toString())
                                  : const AssetImage('images/no_image.png')
                                      as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.pet.name,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(widget.pet.description),
                    ],
                  ),
                ),
                Container(
                  height: 120.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      const SizedBox(height: 16.0),
                      getWidget('Age', widget.pet.age.toString()),
                      getWidget('Sex', widget.pet.sex),
                      getWidget('Weight', widget.pet.weight),
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
                  margin:
                      const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
                  width: double.infinity,
                  height: 90.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2D0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
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
                    title: Text(widget.pet.ownerName),
                    subtitle: const Text("Owner"),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  title: Text(widget.pet.emailID),
                  subtitle: const Text("Contact with above email"),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFED7A4D),
              ),
              child: Text('PetPal'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MyHomePage(),
                ));
              },
            ),
            ListTile(
              title: const Text('Add pet'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddPetScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Pet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Adopt',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
