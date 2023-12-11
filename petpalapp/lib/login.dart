import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petpalapp/screens/home_screen.dart';
import 'package:petpalapp/view_model/user_view_model.dart' as petpaluser;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  petpaluser.User? appUser;
  void _authenticate() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      await getUserDetails(_emailController.text);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(
                  appUser: appUser,
                )),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (kDebugMode) {
        print('error code is ${e.code}');
      }
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        errorMessage = 'Invalid Login credentials';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'too-many-request') {
        errorMessage = 'Access to this account has been temporarily disabled due to many failed login attempts.';
      } else {
        errorMessage = 'error in login authentication';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), duration: const Duration(seconds: 4), behavior: SnackBarBehavior.fixed));
    }
  }

  Future<void> getUserDetails(String userEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users') // Change to your collection name
          .where('email', isEqualTo: userEmail)
          .limit(1) // Assuming there's only one user with the same email
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming each document in the "users" collection has a "name" field
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
        body: Container(
            color: Color(0xFFF5EDE2),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/LoginPage.png'),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'username',
                        icon: Icon(Icons.person),
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'password',
                        icon: Icon(Icons.lock),
                      ),
                    )),
                ElevatedButton(
                  onPressed: _authenticate,
                  child: const Text('Login'),
                ),
              ],
            ))));
  }
}
