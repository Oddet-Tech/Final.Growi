import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growi_project/appscreen/forgotpass.dart';
import 'package:growi_project/appscreen/realappscreen.dart';
import 'package:growi_project/admin.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  // =========================
  // CHECK IF USER IS ADMIN
  // =========================
  Future<bool> _isAdminUser(String uid) async {
    try {
      final adminDoc =
          await _firestore.collection('admins').doc(uid).get();

      return adminDoc.exists;
    } catch (e) {
      debugPrint("Admin Check Error: $e");
      return false;
    }
  }

  // =========================
  // CHECK IF USER PROFILE EXISTS
  // =========================
  Future<DocumentSnapshot?> _getUserProfile(String uid) async {
    try {
      // FIRST PROFILE COLLECTION
      final userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc;
      }

      // SECOND PROFILE COLLECTION
      final customerDoc =
          await _firestore.collection('customers').doc(uid).get();

      if (customerDoc.exists) {
        return customerDoc;
      }

      // NO PROFILE FOUND
      return null;
    } catch (e) {
      debugPrint("Profile Check Error: $e");
      return null;
    }
  }

  // =========================
  // LOGIN FUNCTION
  // =========================
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // LOGIN WITH FIREBASE AUTH
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("User not found");
      }

      // =========================
      // CHECK ADMIN
      // =========================
      final bool isAdmin = await _isAdminUser(user.uid);

      if (isAdmin) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Admin(),
          ),
        );

        return;
      }

      // =========================
      // CHECK USER PROFILE
      // =========================
      final profileDoc = await _getUserProfile(user.uid);

      // NO PROFILE FOUND
      if (profileDoc == null) {
        await _auth.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No profile account found for this user.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // =========================
      // GET USER DATA
      // =========================
      final data = profileDoc.data() as Map<String, dynamic>;

      final String userName = data['name'] ?? 'User';
      final String userEmail = data['email'] ?? email;

      // =========================
      // GO TO HOME SCREEN
      // =========================
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RealHome(
            name: userName,
            email: userEmail,
          ),
        ),
      );
    }

    // =========================
    // FIREBASE AUTH ERRORS
    // =========================
    on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";

      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Incorrect email or password";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }

    // =========================
    // OTHER ERRORS
    // =========================
    catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        backgroundColor: const Color(0xFFF8EED2),
      ),
      backgroundColor: const Color(0xFFF8EED2),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // EMAIL FIELD
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Invalid email address';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD FIELD
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // LOGIN BUTTON
                    SizedBox(
                      width: screenWidth * 0.6,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(
                            255,
                            230,
                            228,
                            185,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // FORGOT PASSWORD
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPass(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          decoration:
                              TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}