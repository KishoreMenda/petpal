import 'package:flutter/material.dart';
import 'package:petpalapp/screens/add_pet_screen.dart';
import 'package:petpalapp/screens/home_screen.dart';
import 'package:petpalapp/view_model/pet_view_model.dart';

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
                    leading: const CircleAvatar(
                      child: ClipOval(
                        child: Image(
                          height: 40.0,
                          width: 40.0,
                          image: AssetImage('images/user.png'),
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
