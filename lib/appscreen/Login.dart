import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growi_project/appscreen/forgotpass.dart';
import 'package:growi_project/appscreen/realappscreen.dart';
import 'package:growi_project/admin.dart';
import 'package:growi_project/services/auth_service.dart';

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

  StreamSubscription<User?>? _authSubscription;
  bool _waitingForEmailVerification = false;
  bool _isLoading = false;

//check if user is admin
  Future<bool> _isAdminUser(String uid) async {
  try {
    debugPrint("Checking admin for UID: $uid");

    final adminDoc =
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(uid)
            .get();

    debugPrint("Document exists: ${adminDoc.exists}");

    if (adminDoc.exists) {
      debugPrint(adminDoc.data().toString());
    }

    return adminDoc.exists;
  } catch (e) {
    debugPrint("Admin Error: $e");
    return false;
  }
}
  //check if user account exists
  Future<DocumentSnapshot?> _getUserProfile(String uid) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc;
      }
      final customerDoc =
          await _firestore.collection('customers').doc(uid).get();
      if (customerDoc.exists) {
        return customerDoc;
      }
      return null;
    } catch (e) {
      debugPrint("Profile Check Error: $e");
      return null;
    }
  }
  Future<void> _ensureUserProfile(User user, String fallbackEmail) async {
    await AuthService.ensureUserProfile(user, fallbackEmail: fallbackEmail);
  }
  Future<void> _handleAuthStateChanged(User? user) async {
    if (!mounted || user == null || !_waitingForEmailVerification) {
      return;
    }
    await user.reload();
    final refreshedUser = _auth.currentUser;
    if (refreshedUser == null || !refreshedUser.emailVerified) {
      return;
    }
    await _firestore.collection('users').doc(refreshedUser.uid).set(
  {
    'emailVerified': true,
  },
  SetOptions(merge: true),
);
    _waitingForEmailVerification = false;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verified successfully. Access granted.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
    await _navigateAfterAuthentication(refreshedUser, refreshedUser.email ?? '');
  }
  Future<void> _navigateAfterAuthentication(User user, String fallbackEmail) async {
   final bool isAdmin = await _isAdminUser(user.uid);
    debugPrint("Is Admin: $isAdmin");
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
    await _ensureUserProfile(user, fallbackEmail);
    final profileDoc = await _getUserProfile(user.uid);
    final data = (profileDoc?.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
    final String userName = (data['name'] ??
        data['fullName'] ??
        data['displayName'] ??
        user.displayName ??
        '')
      .toString();
    final String userEmail = (data['email'] ?? fallbackEmail).toString();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => RealHome(
          name: userName,
          email: userEmail,
        ),
      ),
      (route) => false,
    );
  }


  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      // LOGIN WITH FIREBASE AUTH
      final UserCredential userCredential =
          await AuthService.signIn(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("User not found");
      }
      await user.reload();
      final refreshedUser = _auth.currentUser;
      final currentUser = refreshedUser ?? user;
    if (!currentUser.emailVerified){
        await user.sendEmailVerification();
        await _auth.signOut();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _waitingForEmailVerification = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please verify your email before logging in. '
              'A verification email has been sent to your address.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 6),
          ),
        );

        return;
      }

      await _navigateAfterAuthentication(currentUser, email);
    }

    // =========================
    // FIREBASE AUTH ERRORS
    // =========================
    on FirebaseAuthException catch (e) {
      final errorMessage = AuthService.getFriendlyError(e);

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
  void initState() {
    super.initState();
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChanged);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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
                        final email = value?.trim() ?? '';
                        if (!RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(email)) {
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