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
  // bottom navigator
  int _selectedIndex = 0;
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
            builder: (_) => UserProfilePage(appUser: widget.appUser),
          ));
          break;
        }

      case 2:
        {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AddPetScreen(),
          ));
          break;
        }

      default:
        {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MyHomePage(),
          ));
        }
    }
  }

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
          Container(
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            height: 250.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (filteredPets[index]
                        .imageUrl
                        .contains("firebasestorage"))
                    ? NetworkImage(filteredPets[index].imageUrl.toString())
                    : const AssetImage('images/no_image.png') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 40.0, top: 10.0),
            child: Text(
              filteredPets[index].name,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
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
        setState(() {
          currentCategoryIndex = itemIndex;
          categoriesIndex = currentCategoryIndex;
        }),
      },
      child: Container(
        margin: const EdgeInsets.all(9.0),
        width: 60.0,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFED7A4D) : const Color(0xFFF8F2F7),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
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

    categoriesIndex = currentCategoryIndex;
    widget.firebaseStoreage.setOnDataChangedCallback(() async {
      setState(() {});
    });
  }

  Widget getHomePage() {
    return Container(
      height: double.infinity,
      color: const Color(0xFFF5EDE2),
      child: ListView(
        children: <Widget>[
          const SizedBox(height: 10.0),
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
                    return _buildPetItem(index == currentCategoryIndex, index);
                  })),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EDE2),
      ),
      body: Container(
        height: double.infinity,
        color: Color(0xFFF5EDE2),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 40.0),
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
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFFED7A4D),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('PetPal'),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserProfilePage(appUser: widget.appUser),
                            ),
                          )
                        },
                        child: const ClipOval(
                          child: Image(
                            height: 50.0,
                            width: 50.0,
                            image: AssetImage('images/user.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ])),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MyHomePage(),
                ));
              },
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => UserProfilePage(appUser: widget.appUser),
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
            ListTile(
              title: const Text('Sign Out'),
              onTap: () {
                handleSignOut(context);
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add pet',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
