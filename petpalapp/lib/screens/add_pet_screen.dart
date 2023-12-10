import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:petpalapp/storage.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as geo;
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'package:petpalapp/screens/map_screen.dart';
import 'package:http/http.dart' as http;

class AddPetScreen extends StatefulWidget {
  AddPetScreen();

  final CounterStorage firebaseStoreage = CounterStorage();

  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class UserData extends ChangeNotifier {
  String name = "";
  String location = "";
  String imagePath = "";

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setLocation(String value) {
    location = value;
    notifyListeners();
  }

  void setImage(String value) {
    imagePath = value;
    notifyListeners();
  }
}

class _AddPetScreenState extends State<AddPetScreen> {
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerQuantity = TextEditingController();

  MapController mapController = MapController();
  LocationData? currentLocation;
  LatLng? selectedLocation;

  GlobalKey<FormState> key = GlobalKey();
  File? _image;
  late Future<Position> _position;
  late Stream<Position> positionStream;
  late StreamSubscription<Position> positionSubscriberStream;

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('petpal_db');

  String imageUrl = '';
  String name = '';
  String gender = '';
  String age = '';
  String weight = '';
  String description = '';
  String owner = '';
  String petType = '';
  String selectedPetType = 'Cat';
  String latitude = '';
  String longitude = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF5EDE2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Color(0xFFF5EDE2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _showOptions,
                  child: ClipOval(
                    child: _image != null
                        ? Image.file(
                            _image!,
                            width: 188,
                            height: 188,
                            fit: BoxFit
                                .cover, // Use BoxFit.cover to maintain aspect ratio and cover the specified dimensions
                          )
                        : Container(
                            width: 188,
                            height: 188,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                            ),
                            child: const Center(
                              child: Text(
                                'Add Photo',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: selectedPetType, // Set the default value
                onChanged: (String? newValue) {
                  // Handle the user's selection
                  print(newValue);

                  setState(() {
                    selectedPetType = newValue!;
                  });
                },
                items: <String>['Cat', 'Dog', 'Bird', 'Others']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      child: Center(
                        child: Text(value),
                      ),
                    ),
                  );
                }).toList(),
              ),
              TextField(
                onChanged: (value) => {
                  print("onChanged $value"),
                  name = value,
                },
                decoration: InputDecoration(labelText: 'Pet Name'),
              ),
              TextField(
                onChanged: (value) => {
                  print("onChanged $value"),
                  gender = value,
                },
                decoration: InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                onChanged: (value) => {
                  print("onChanged $value"),
                  age = value,
                },
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextField(
                onChanged: (value) => {
                  print("onChanged $value"),
                  weight = value,
                },
                decoration: InputDecoration(labelText: 'Weight'),
              ),
              TextField(
                onChanged: (value) => {
                  print("onChanged $value"),
                  description = value,
                },
                //                 maxLines: null, // Set this to null or any desired number greater than 1
                // keyboardType: TextInputType.multiline,
                decoration: InputDecoration(labelText: 'Description '),
              ),
              TextField(
                onChanged: (value) => {
                  print("onChanged $value"),
                  owner = value,
                },
                decoration: InputDecoration(labelText: 'Owner'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  print('Clicked on mapssss');
                  // Open the MapScreen and get the selected location
                  try {
                    LatLng? location =
                        await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MapScreen(
                        initialLocation: LatLng(
                          double.parse(latitude),
                          double.parse(longitude),
                        ),
                      ),
                    ));

                    // Update the selected location in the state
                    if (location != null) {
                      setState(() {
                        selectedLocation = location;
                        latitude = selectedLocation!.latitude.toString();
                        longitude = selectedLocation!.longitude.toString();
                      });
                      print('Selected Location: $selectedLocation');
                    }
                  } catch (e) {
                    print('Error parsing latitude/longitude: $e');
                  }
                },
                child: Text('Set Location on Map'),
              ),
              // Text(
              //   'Selected Location on Map: ${selectedLocation?.latitude ?? ''}, ${selectedLocation?.longitude ?? ''}',
              // ),
              const SizedBox(height: 16.0),
              FutureBuilder<Position>(
                future: _position,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Text('No data available');
                  } else {
                    latitude = snapshot.data!.latitude.toString();
                    longitude = snapshot.data!.longitude.toString();
                    return Text(
                      'Present location: ${latitude}, ${longitude}',
                    );
                  }
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  //Get a reference to storage root
                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDirImages = referenceRoot.child('images');
                  //Create a reference for the image to be stored
                  Reference referenceImageToUpload =
                      referenceDirImages.child(uniqueFileName);

                  //Handle errors/success
                  try {
                    //Store the file
                    if (_image == null ||
                        name == '' ||
                        gender == '' ||
                        age == '' ||
                        weight == '' ||
                        description == '' ||
                        owner == '') {
                      showToast('Fill all the info');
                      print(
                          "_image $_image name $name gender $gender  age  $age weight  $weight description  $description  owner  $owner");
                      return;
                    } else {
                      print("putFile ${_image?.path}");
                      await referenceImageToUpload.putFile(_image!);
                      //Success: get the download URL
                      imageUrl = await referenceImageToUpload.getDownloadURL();
                      print("Download URL $imageUrl");
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$imageUrl')));
                    }
                  } catch (error) {
                    //Some error occurred
                    print("Failed to upload image $error");
                  }

                  print("Name: ${name}");
                  // print("Location: ${userData.location}");
                  print("Image Path: ${imageUrl}");

                  await widget.firebaseStoreage.writePetDetailsMap({
                    "owner": owner,
                    "petType": selectedPetType,
                    "name": name,
                    "imageUrl": imageUrl,
                    "description": description,
                    "age": age,
                    "sex": gender,
                    "color": 'Black',
                    "id": '12345',
                    "latit": latitude,
                    "longit": longitude
                  });
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _position = _determinePosition();
    LocationSettings locationSettings = LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);
    positionSubscriberStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (kDebugMode) {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
      }
    });
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Future<String> _getLocation() async {
  //   Location location = Location();
  //   LocationData locationData = await location.getLocation();
  //   return "Lat: ${locationData.latitude}, Long: ${locationData.longitude}";
  //   // return "";
  // }

  void _pickImageFromCamera() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
    print('${file?.path}');

    if (file == null) return;

    setState(() {
      _image = File(file.path);
    });

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    //Get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    //Create a reference for the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    //Handle errors/success
    try {
      //Store the file
      print("putFile ${file.path}");
      await referenceImageToUpload.putFile(File(file.path));
      //Success: get the download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();
      print("Download URL $imageUrl");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$imageUrl')));
    } catch (error) {
      //Some error occurred
      print("Failed to upload image $error");
    }
  }

  Future<File?> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
