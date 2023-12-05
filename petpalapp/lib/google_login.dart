// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petpalapp/firebase_options.dart';
import 'package:petpalapp/screens/home_screen.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class GoogleLogin extends StatefulWidget {
  const GoogleLogin({super.key});

  @override
  State<GoogleLogin> createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  GoogleSignInAccount? googleUser;
  bool _initialized = false;

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
    // Trigger the authentication flow
    if (!_initialized) {
      await initializeDefault();
    }
    // Trigger the authentication flow
    googleUser = await GoogleSignIn().signIn();
    if (kDebugMode) {
      print('The google user is ------------------------- $googleUser');
    }
    if (googleUser != null) {
      if (kDebugMode) {
        print(googleUser!.email);
      }
    }
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    if (kDebugMode) {
      print('The google auth is ---------------------------$googleAuth');
    }

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    setState(() {});

    // Once signed in, return the UserCredential
    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('login with google'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: getBody(),
      )),
    );
  }

  List<Widget> getBody() {
    List<Widget> body = [];

    body.add(ElevatedButton(
      onPressed: () async {
        UserCredential userCredential = await signInWithGoogle();
        // Use the captured context outside the async gap
        await Future<void>.delayed(Duration.zero);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(googleUser: googleUser),
          ),
        );
      },
      child: const Text("Sign in with Google"),
    ));

    return body;
  }
}
