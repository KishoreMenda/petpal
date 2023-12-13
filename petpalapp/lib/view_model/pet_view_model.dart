import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petpalapp/signup.dart';

// used https://www.youtube.com/watch?app=desktop&v=7eu_U6UClik as reference to decide on code structuring
class Category {
  String name;
  String type;

  Category({
    required this.name,
    required this.type
  });
}

class Pet {
  final String ownerName;
  final String name;
  final String imageUrl;
  final String description;
  final String age;
  final String sex;
  final String weight;
  final String petType;
  final String emailID;
  final String phoneNumber;
  final String latit;
  final String longit;

  Pet({
    required this.ownerName,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.age,
    required this.sex,
    required this.weight,
    required this.petType,
    required this.emailID,
    required this.phoneNumber,
    required this.latit,
    required this.longit
  });
}

var categories = [
  Category(name: 'All', type: 'all'),
  Category(name: 'Cats', type: 'Cat'),
  Category(name: 'Dogs', type: 'Dog'),
  Category(name: 'Birds', type: 'Bird'),
  Category(name: 'Others', type: 'Other'),
];

var filteredPets = [];
var lastFilterType = 'all';
var pets = [];
var categoriesIndex = 0;
var currentUserPets = [];

Future updatedSortedList(String petType) async {
  print("manasash $lastFilterType input $petType");
  lastFilterType = petType;
  if (petType.toLowerCase() == 'all') {
    filteredPets = pets;
  } else if (petType.toLowerCase() == 'other') {
    filteredPets = pets
        .where((pet) =>
            !['dog', 'cat', 'bird'].contains(pet.petType.toLowerCase()))
        .toList();
  } else {
    filteredPets = pets
        .where((pet) => pet.petType.toLowerCase() == petType.toLowerCase())
        .toList();
  }

  print('updatedSortedList($petType)   $filteredPets');
}

Future<void> handleSignOut(BuildContext context) async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();

      // Navigate to the login or home screen after sign-out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignupPage(),
        ),
      );
    } catch (error) {
      print("Error signing out: $error");
    }
  }

//   Future updatedSortedList(String petType) async {
//   print("manasash $lastFilterType input $petType");
//   lastFilterType = petType;

//   currentUserPets = pets
//         .where((pet) => pet.petType.toLowerCase() == petType.toLowerCase())
//         .toList();

//   print('updatedSortedList($petType)   $filteredPets');
// }
