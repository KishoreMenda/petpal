import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../view_model/pet_view_model.dart';

class FavoritePetsScreen extends StatefulWidget {
  String userEmail;

  FavoritePetsScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<FavoritePetsScreen> createState() => _FavoritePetsScreenState();
}

class _FavoritePetsScreenState extends State<FavoritePetsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Pets'),
      ),
      body: FutureBuilder<List<Pet>>(
        future: fetchFavoritePets(widget.userEmail),
        builder: (context, snapshot) {
          if (kDebugMode) {
            print('Data : ${snapshot.hasData}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorite pets found.'));
          } else {
            List<Pet> favoritePets = snapshot.data!;
            return ListView.builder(
              itemCount: favoritePets.length,
              itemBuilder: (context, index) {
                Pet pet = favoritePets[index];
                return ListTile(
                  title: Text(pet.name),
                  subtitle: Text('Type: ${pet.petType}'),
                  // Add more details as needed
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Pet>> fetchFavoritePets(String userEmail) async {
    if (kDebugMode) {
      print('The emaul isssssssssssssssR: ${userEmail}');
    }
    try {
      // Reference to the user's favorite pets collection
      CollectionReference favoritePetsCollection = FirebaseFirestore.instance.collection('favorites').doc(userEmail).collection('favoritePets');
      print('The collection count is ------------->: ${favoritePetsCollection.count().get()}');

      // Get documents from the collection
      QuerySnapshot querySnapshot = await favoritePetsCollection.get();

      // Convert documents to Pet objects
      List<Pet> favoritePets = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (kDebugMode) {
          print('object ${data}');
        }
        return Pet(
          // Map data to the Pet class fields
          name: data['name'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          age: data['age'] ?? '',
          sex: data['sex'] ?? '',
          weight: data['weight'] ?? '',
          petType: data['petType'] ?? '',
          latit: data['latit'] ?? '',
          longit: data['longit'] ?? '',
          owner: data['Owner'],
          ownerName: data['ownerName'],
          emailID: data['Owner'],
          phoneNumber: data['phoneNumber'],
        );
      }).toList();

      return favoritePets;
    } catch (e) {
      // Handle the exception (e.g., show an error message)
      print('Error fetching favorite pets: $e');
      return [];
    }
  }
}
