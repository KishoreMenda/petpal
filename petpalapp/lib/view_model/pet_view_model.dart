import 'package:petpalapp/view_model/category_view_model.dart';

import 'owner_view_model.dart';

class Pet {
  final Owner owner;
  final String name;
  final String imageUrl;
  final String description;
  final String age;
  final String sex;
  final String color;
  final String id;
  final String petType;
  final String latit;
  final String longit;

  Pet(
      {required this.owner,
      required this.name,
      required this.imageUrl,
      required this.description,
      required this.age,
      required this.sex,
      required this.color,
      required this.id,
      required this.petType,
      required this.latit,
      required this.longit});
}

var categories = [
  Category(name: 'All', type: 'all'),
  Category(name: 'Cats', type: 'Cat'),
  Category(name: 'Dogs', type: 'Dog'),
  Category(name: 'Birds', type: 'Bird'),
  Category(name: 'Others', type: 'Other'),
];

var owner = Owner(
    name: 'Roselia Drew',
    imageUrl: 'images/user.png',
    bio:
        'I recently lost my job and don\'t have enough time or money to tend to Darlene anymore. I have a lot of health issues that need attention and want to give Darlene the best life possible.');
var filteredPets = [];
var lastFilterType = '';
var pets = [
  // Pet(
  //   owner: owner,
  //   name: 'Pupper Katherine',
  //   imageUrl: 'images/lab.png',
  //   description: 'French black puppy',
  //   age: 2,
  //   sex: 'Female',
  //   color: 'Black',
  //   id: 12345,
  // ),
  // Pet(
  //   owner: owner,
  //   name: 'Little Darlene',
  //   imageUrl: 'images/pug.jpg',
  //   description: 'Labrador retriever puppy',
  //   age: 1,
  //   sex: 'Female',
  //   color: 'White',
  //   id: 98765,
  // ),
  //   Pet(
  //   owner: owner,
  //   name: 'Pupper Katherine',
  //   imageUrl: 'images/lab.png',
  //   description: 'French black puppy',
  //   age: 2,
  //   sex: 'Female',
  //   color: 'Black',
  //   id: 12345,
  // ),
  // Pet(
  //   owner: owner,
  //   name: 'Little Darlene',
  //   imageUrl: 'images/pug.jpg',
  //   description: 'Labrador retriever puppy',
  //   age: 1,
  //   sex: 'Female',
  //   color: 'White',
  //   id: 98765,
  // ),
  //   Pet(
  //   owner: owner,
  //   name: 'Pupper Katherine',
  //   imageUrl: 'images/lab.png',
  //   description: 'French black puppy',
  //   age: 2,
  //   sex: 'Female',
  //   color: 'Black',
  //   id: 12346,
  // ),
  // Pet(
  //   owner: owner,
  //   name: 'Little Darlene',
  //   imageUrl: 'images/pug.jpg',
  //   description: 'Labrador retriever puppy',
  //   age: 1,
  //   sex: 'Female',
  //   color: 'White',
  //   id: 98767,
  // ),
  //   Pet(
  //   owner: owner,
  //   name: 'Little Darlene',
  //   imageUrl: 'images/pug.jpg',
  //   description: 'Labrador retriever puppy',
  //   age: 1,
  //   sex: 'Female',
  //   color: 'White',
  //   id: 92229,
  // ),
  //   Pet(
  //   owner: owner,
  //   name: 'Little Darlene',
  //   imageUrl: 'images/pug.jpg',
  //   description: 'Labrador retriever puppy',
  //   age: 1,
  //   sex: 'Female',
  //   color: 'White',
  //   id: 92220,
  // ),
];

Future updatedSortedList(String petType) async {
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
