
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
    required this.phoneNumber
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
var lastFilterType = '';
var pets = [];
var categoriesIndex = 0;

Future updatedSortedList(String petType) async {
  lastFilterType = petType;
  if (petType.toLowerCase() == 'all') {
    filteredPets = pets;
  } else if (petType.toLowerCase() == 'other') {
    filteredPets = pets
        .where((pet) => !['dog', 'cat', 'bird'].contains(pet.petType.toLowerCase()))
        .toList();
  } else {
    filteredPets = pets
        .where((pet) => pet.petType.toLowerCase() == petType.toLowerCase())
        .toList();
  }

  print('updatedSortedList($petType)   $filteredPets');
}
