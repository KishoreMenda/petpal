import 'package:petpalapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'view_model/pet_view_model.dart';

class CounterStorage {
  bool _initialized = false;
  VoidCallback? onDataChanged; // Callback to notify listeners
  late Stream<QuerySnapshot> _stream;
  late CollectionReference
      ds; // = FirebaseFirestore.instance.collection("petpal-db");
  Future<void> initializeDefault() async {
    // FirebaseApp app = await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    _initialized = true;

    startListening();

    // print('Initialized default Firebase app $app');
  }

  // Set the callback function using a lambda expression
  void setOnDataChangedCallback(VoidCallback callback) {
    onDataChanged = callback;
  }

  void startListening() {
    print("startListening Manasa: ${pets.length}");
    ds = FirebaseFirestore.instance.collection("petpal-db");
    _stream = ds.snapshots();

    _stream.listen(
      (QuerySnapshot snapshot) {
        // Process the data from the stream
        List<DocumentSnapshot> documents = snapshot.docs;

        pets = documents.map((doc) {
          // Convert each document to a Pet object or use it as needed
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Pet(
              owner: owner,
              name: data['name'].toString(),
              imageUrl: data['imageUrl'].toString(),
              description: data['description'].toString(),
              age: data['age'].toString(),
              sex: data['sex'].toString(),
              color: data['color'].toString(),
              id: data['id'].toString(),
              petType: data['petType'].toString(),
              latit: data['latit'].toString(),
              longit: data['longit'].toString());
        }).toList();
        onDataChanged?.call();
        updatedSortedList(lastFilterType);
        // Process the updated data, you can notify listeners or perform other actions here
        print("Updated Pets: ${pets.length}");
      },
      onError: (error) {
        // Handle the error
        print("Error during stream subscription: $error");
      },
    );
  }

  bool get isInitialized => _initialized;

  CounterStorage() {
    initializeDefault();
  }

  Future<bool> writePetDetailsMap(Map<String, String> inputMap) async {
    try {
      if (!isInitialized) {
        await initializeDefault();
      }
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection("petpal-db")
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set(inputMap)
          .then((value) {
        print("set inputMap sucess");
      }).catchError((error) {
        print("Failed to set counter: $error");
      });
    } catch (e) {
      print(e);
    }

    return false;
  }

  Future<bool> writeUserDetails(Map<String, String> inputMap) async {
    try {
      if (!isInitialized) {
        await initializeDefault();
      }
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection("users")
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set(inputMap)
          .then((value) {
        print("Set user details successfully");
      }).catchError((error) {
        print("Failed to set user details: $error");
      });
    } catch (e) {
      print(e);
    }

    return false;
  }

  Future<bool> writePetDetails(int counter) async {
    try {
      if (!isInitialized) {
        await initializeDefault();
      }
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection("petpal-db")
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set({
        "count": counter.toString(),
        "owner": 'owner',
        "name": 'Pupper 123123123',
        "imageUrl": 'images/lab.png',
        "description": 'French black puppy',
        "age": '2',
        "sex": 'Female',
        "color": 'Black',
        "id": '12345'
      }).then((value) {
        print("set counter: $counter sucess");
      }).catchError((error) {
        print("Failed to set counter: $error");
      });
    } catch (e) {
      print(e);
    }

    return false;
  }

  Future<bool> writeCounter(int counter) async {
    return writePetDetails(counter);
    try {
      if (!isInitialized) {
        await initializeDefault();
      }
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection("assignment5")
          .doc("counter")
          .set({"count": counter}).then((value) {
        print("set counter: $counter sucess");
      }).catchError((error) {
        print("Failed to set counter: $error");
      });
    } catch (e) {
      print(e);
    }

    return false;
  }

  // Future<Map<String, dynamic>> readPetDetails() async {
  //    try {
  //     if (!isInitialized) {
  //       await initializeDefault();
  //     }

  //     FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     CollectionReference ds = firestore.collection("petpal-db");

  //     if (ds.exists && ds.data() != null) {
  //       Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
  //       if (data.containsKey("count")) {
  //         return data;
  //       }
  //     }
  //     bool writeSuccess = await writeCounter(0);
  //     if (writeSuccess) {
  //       return {};
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  //   return {};
  // }

  Future<int> readCounter() async {
    try {
      if (!isInitialized) {
        await initializeDefault();
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot ds =
          await firestore.collection("assignment5").doc("counter").get();

      if (ds.exists && ds.data() != null) {
        Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
        if (data.containsKey("count")) {
          return data["count"];
        }
      }
      bool writeSuccess = await writeCounter(0);
      if (writeSuccess) {
        return 0;
      }
    } catch (e) {
      print(e);
    }
    return -1;
  }
}
