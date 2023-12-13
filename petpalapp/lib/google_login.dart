import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petpalapp/firebase_options.dart';
import 'package:petpalapp/screens/home_screen.dart';
import 'package:petpalapp/storage.dart';
import 'package:petpalapp/view_model/user_view_model.dart' as petpaluser;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class GoogleLogin extends StatefulWidget {
  GoogleLogin({super.key});
  final CounterStorage firebaseStorage = CounterStorage();

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  GoogleSignInAccount? googleUser;
  bool _initialized = false;
  petpaluser.User? appUser;

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
    if (kDebugMode) {
      print("Initialized default Firebase app ------------$app");
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!_initialized) {
      await initializeDefault();
    }
    googleUser = await GoogleSignIn().signIn();
    if (kDebugMode) {
      print('The google user is ------------------------- $googleUser');
    }
    if (googleUser != null) {
      if (kDebugMode) {
        print(googleUser!.email);
      }
    }
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (kDebugMode) {
      print('The google auth is ---------------------------$googleAuth');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    storeUserInFirebase(googleUser!);
    setState(() {});

    return userCredential;
  }

  Future<void> storeUserInFirebase(GoogleSignInAccount googleUser) async {
    try {
      Map<String, String> userMap = {
        'name': googleUser.displayName ?? '',
        'email': googleUser.email ?? '',
      };

      await widget.firebaseStorage.writeUserDetails(userMap);

      print('Google User details stored in Firebase.');
    } catch (e) {
      print('Error storing Google User details: $e');
    }
  }

  Future<void> getUserDetails(String userEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: userEmail).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        String u_name = querySnapshot.docs.first.get('name');
        String u_email = querySnapshot.docs.first.get('email');
        appUser = petpaluser.User(name: u_name, email: u_email);
      } else {
        print('User not found in Firebase with email: $userEmail');
      }
    } catch (e) {
      print('Error retrieving user details from Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('login with google'),
          backgroundColor: const Color(0xFFF5EDE2),
        ),
        body: Container(
            color: Color(0xFFF5EDE2),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: getBody(),
            ))));
  }

  List<Widget> getBody() {
    List<Widget> body = [];

    body.add(ElevatedButton(
      onPressed: () async {
        UserCredential userCredential = await signInWithGoogle();
        await getUserDetails(googleUser!.email);

        await Future<void>.delayed(Duration.zero);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(appUser: appUser),
          ),
        );
      },
      child: const Text("Sign in with Google"),
    ));

    return body;
  }
}
