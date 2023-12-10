import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petpalapp/login.dart';
import 'package:petpalapp/google_login.dart';
import 'package:petpalapp/storage.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  final CounterStorage firebaseStorage = CounterStorage();
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (userCredential != null) {
          storeUserInFirebase();
        }
        if (kDebugMode) {
          print('User email: ${_emailController.text}');
        }
        if (kDebugMode) {
          print('password: ${_passwordController.text}');
        }

        // Navigate to the sign-in page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          if (kDebugMode) {
            print('The password provided is too weak.');
          }
        } else if (e.code == 'email-already-in-use') {
          if (kDebugMode) {
            print('The account already exists for that email.');
          }
        }
      } catch (e) {
        print('the error is: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                color: Colors.white,
                child: Center(
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40.0), // Added padding at the top
                            const Text(
                              'Welcome to PetPal!',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    hintText: 'First Name',
                                    icon: Icon(Icons.person),
                                  ),
                                )),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Last Name',
                                    icon: Icon(Icons.person),
                                  ),
                                )),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'e-mail',
                                    icon: Icon(Icons.email),
                                  ),
                                  validator: _validateEmail,
                                )),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  hintText: 'Password',
                                  icon: Icon(Icons.lock),
                                ),
                                obscureText: true,
                                validator: _validatePassword,
                              ),
                            ),
                            ElevatedButton(onPressed: _submitForm, child: const Text('Sign Up')),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 1.0,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              child: const Text('Login with email/password'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GoogleLogin(),
                                  ),
                                );
                              },
                              child: const Text('Sign in with Google'),
                            ),
                          ],
                        ))))));
  }

  Future<void> storeUserInFirebase() async {
    try {
      // Create a map with user details
      String fullName = '${_firstNameController.text} ${_lastNameController.text}';
      String email = _emailController.text;

      // Create a map with user details
      Map<String, String> userMap = {
        'name': fullName,
        'email': email,
      };
      // Call the writePetDetailsMap function to store the user details in Firebase
      await widget.firebaseStorage.writeUserDetails(userMap);

      print('Google User details stored in Firebase.');
    } catch (e) {
      print('Error storing Google User details: $e');
    }
  }
}
