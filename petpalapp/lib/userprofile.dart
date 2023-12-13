import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petpalapp/signup.dart';
import 'package:petpalapp/view_model/user_view_model.dart';

//used chatgpt for some syntax
class UserProfilePage extends StatelessWidget {
  User? appUser;
  UserProfilePage({Key? key, this.appUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Color(0xFFF5EDE2),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Color(0xFFF5EDE2),
        child: Column(
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
      ),
    );
  }

//used help of flutter dcoumententation and chatgpt to handle signout for which functions to use
  Future<void> _handleSignOut(BuildContext context) async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();

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
