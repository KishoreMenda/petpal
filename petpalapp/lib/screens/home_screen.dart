import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:petpalapp/screens/add_pet_screen.dart';
import 'package:petpalapp/screens/adopt_pet_screen.dart';
import 'package:petpalapp/storage.dart';
import 'package:petpalapp/userprofile.dart';
import 'package:petpalapp/view_model/pet_view_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petpalapp/view_model/user_view_model.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.appUser}) : super(key: key);
  final User? appUser;

  final CounterStorage firebaseStoreage = CounterStorage();
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentCategoryIndex = 0;
  // late Future<int> _firebase_counter;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _petsScrollController = ScrollController();

  // Future<void> _incrementCounter_firebase() async {
  //   int count = await widget.firebaseStoreage.readCounter();
  //   count++;
  //   await widget.firebaseStoreage.writeCounter(count);
  //   setState(() {
  //     _firebase_counter = widget.firebaseStoreage.readCounter();
  //   });
  // }

  // Future<void> _decrementCounter_firebase() async {
  //   int count = await widget.firebaseStoreage.readCounter();
  //   count--;
  //   await widget.firebaseStoreage.writeCounter(count);
  //   setState(() {
  //     _firebase_counter = widget.firebaseStoreage.readCounter();
  //   });
  // }

  Widget _buildPetItem(bool isSelected, int index) {
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdoptPetScreen(pet: filteredPets[index]),
          ),
        ),
        print('Selected $index ')
      },
      child: Column(
        children: <Widget>[
          Hero(
            tag: filteredPets[index].id,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              height: 250.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
                image: DecorationImage(
                  // image: pets[index]
                  //         .imageUrl
                  //         .toString()
                  //         .contains("firebasestorage")
                  //     ? NetworkImage(pets[index].imageUrl.toString())
                  //     : AssetImage(pets[index].imageUrl.toString()),
                  image: (filteredPets[index]
                          .imageUrl
                          .contains("firebasestorage"))
                      ? NetworkImage(filteredPets[index].imageUrl.toString())
                      : const AssetImage('images/lab.png') as ImageProvider,

                  // image: NetworkImage(pets[index].imageUrl.toString()),
                  //  image: AssetImage(pets[index].imageUrl.toString()),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Text(
            filteredPets[index].name,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            iconSize: 30.0,
            color: Theme.of(context).primaryColor,
            onPressed: () => print('Favorite ${filteredPets[index].name}'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCategory(bool isSelected, int itemIndex, String category) {
    return GestureDetector(
      onTap: () async => {
        print(
            'currentCategoryIndex $currentCategoryIndex categories[currentCategoryIndex].name ${categories[itemIndex].name}'),

        await updatedSortedList(categories[itemIndex].type),

        //  List<Map<String, dynamic>> filteredList = pets
        //   .map((dynamic item) => item as Map<String, dynamic>)
        //   .toList().where((pet) => pet['petType'] == categories[currentCategoryIndex].name).toList();

        setState(() {
          currentCategoryIndex = itemIndex;
        }),
        // print('Selected $category currentCategoryIndex $currentCategoryIndex'),
        // if (currentCategoryIndex == 1)
        //   {_decrementCounter_firebase()}
        // else
        //   {_incrementCounter_firebase()}
      },
      child: Container(
        margin: const EdgeInsets.all(10.0),
        width: 80.0,
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Color(0xFFF8F2F7),
          borderRadius: BorderRadius.circular(20.0),
          border: isSelected
              ? Border.all(
                  width: 8.0,
                  color: const Color(0xFFFED8D3),
                )
              : null,
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.firebaseStoreage.setOnDataChangedCallback(() async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: double.infinity,
          color: Color(0xFFF5EDE2),
          child: ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 40.0, top: 40.0),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to UserProfileScreen when the CircleAvatar is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(appUser: widget.appUser),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    child: ClipOval(
                      child: Image(
                        height: 40.0,
                        width: 40.0,
                        image: AssetImage(owner.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddPetScreen(),
                    ),
                  );
                },
                child: Text('Add new pet info'),
              ),
              const SizedBox(height: 40.0),
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 40.0),
              //   child: TextField(
              //     style: TextStyle(
              //       fontFamily: 'Montserrat',
              //       fontSize: 22.0,
              //     ),
              //     decoration: InputDecoration(
              //       border: InputBorder.none,
              //       prefixIcon: Padding(
              //         padding: EdgeInsets.only(right: 30.0),
              //         child: Icon(
              //           Icons.add_location,
              //           color: Colors.black,
              //           size: 40.0,
              //         ),
              //       ),
              //       labelText: 'Location',
              //       labelStyle: TextStyle(
              //         fontSize: 20.0,
              //         color: Colors.grey,
              //       ),
              //       contentPadding: EdgeInsets.only(bottom: 20.0),
              //     ),
              //   ),
              // ),
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
              //   child: Divider(),
              // ),
              SizedBox(
                  height: 100.0,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildPetCategory(index == currentCategoryIndex,
                            index, categories[index].name);
                      })),
              SizedBox(
                  height: 600.0,
                  width: 500.0,
                  child: ListView.builder(
                      controller: _petsScrollController,
                      itemCount: filteredPets.length,
                      itemBuilder: (context, index) {
                        return _buildPetItem(
                            index == currentCategoryIndex, index);
                      })),
            ],
          ),
        ));
  }
}
