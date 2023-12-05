import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:petpalapp/storage.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  GlobalKey<FormState> key = GlobalKey();
  File? _image;

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
                items:
                    <String>['Cat', 'Dog', 'Bird', 'Others'].map((String value) {
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
                  String location = await _getLocation();
                  context.read<UserData>().setLocation(location);
                },
                child: Text('Choose Location'),
              ),
              const SizedBox(height: 16.0),
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
                    "id": '12345'
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

  Future<String> _getLocation() async {
    Location location = Location();
    LocationData locationData = await location.getLocation();
    return "Lat: ${locationData.latitude}, Long: ${locationData.longitude}";
    // return "";
  }

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
