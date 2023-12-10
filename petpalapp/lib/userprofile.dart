import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petpalapp/signup.dart';
import 'package:petpalapp/view_model/user_view_model.dart';

class UserProfilePage extends StatelessWidget {
  User? appUser;
  UserProfilePage({Key? key, this.appUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(''),
            radius: 80,
          ),
          SizedBox(height: 16),
          Text(appUser?.name ?? ''),
          SizedBox(height: 8),
          Text(appUser?.email ?? ''),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _handleSignOut(context);
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  // Function to handle Google Sign Out
  Future<void> _handleSignOut(BuildContext context) async {
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
}
