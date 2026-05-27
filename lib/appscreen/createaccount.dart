import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewAccountScreen extends StatefulWidget {
  const NewAccountScreen({super.key});

  @override
  State<NewAccountScreen> createState() =>
      _NewAccountScreenState();
}

class _NewAccountScreenState
    extends State<NewAccountScreen> {

  // ================= CONTROLLERS =================

  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController
      confirmPasswordController =
      TextEditingController();

  // ================= FIREBASE =================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ================= VARIABLES =================

  bool _isLoading = false;

  bool _obscurePassword = true;

  bool _obscureConfirm = true;

  String? _errorMessage;

  // ================= DISPOSE =================

  @override
  void dispose() {

    fullNameController.dispose();

    emailController.dispose();

    passwordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();
  }

  // ================= CREATE ACCOUNT =================

  Future<void> _createAccount() async {

    setState(() {
      _errorMessage = null;
    });

    final fullName =
        fullNameController.text.trim();

    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    // ================= VALIDATION =================

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {

      setState(() {
        _errorMessage =
            "Please fill in all fields.";
      });

      return;
    }

    if (password != confirmPassword) {

      setState(() {
        _errorMessage =
            "Passwords do not match.";
      });

      return;
    }

    if (password.length < 6) {

      setState(() {
        _errorMessage =
            "Password must be at least 6 characters.";
      });

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      // ================= CREATE USER =================

      final UserCredential credential =
          await _auth
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception(
          "Account creation failed.",
        );
      }

      // ================= UPDATE DISPLAY NAME =================

      await user.updateDisplayName(
        fullName,
      );

      // ================= SAVE TO FIRESTORE =================

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({

        'uid': user.uid,

        'fullName': fullName,

        'email': email,

        'createdAt':
            FieldValue.serverTimestamp(),

        'emailVerified': false,
      });

      // ================= SEND VERIFICATION EMAIL =================

      await user.sendEmailVerification();

      // ================= SIGN OUT USER =================

      await _auth.signOut();

      if (!mounted) return;

      // ================= SUCCESS MESSAGE =================

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          backgroundColor: Colors.green,

          duration:
              const Duration(seconds: 5),

          content: Text(
            "Account created successfully.\n"
            "A verification email was sent to:\n$email\n\n"
            "Please verify your email before logging in.",
          ),
        ),
      );

      // ================= RETURN TO LOGIN =================

      Navigator.pop(context);

    }

    // ================= FIREBASE ERRORS =================

    on FirebaseAuthException catch (e) {

      String message;

      switch (e.code) {

        case 'email-already-in-use':
          message =
              "An account with this email already exists.";
          break;

        case 'invalid-email':
          message =
              "Please enter a valid email address.";
          break;

        case 'weak-password':
          message =
              "Password is too weak.";
          break;

        default:
          message =
              e.message ??
              "Something went wrong.";
      }

      setState(() {
        _errorMessage = message;
      });
    }

    // ================= OTHER ERRORS =================

    catch (e) {

      setState(() {
        _errorMessage =
            "Unexpected error: $e";
      });
    }

    finally {

      if (mounted) {

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8EED2),

      appBar: AppBar(

        title: const Text(
          'Create New Account',

          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),

        backgroundColor:
            const Color(0xFFF8EED2),

        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: Center(

        child: ListView(

          padding:
              const EdgeInsets.all(16),

          children: [

            const SizedBox(height: 16),

            // ================= EMAIL =================

            TextField(

              controller:
                  emailController,

              keyboardType:
                  TextInputType.emailAddress,

              decoration:
                  const InputDecoration(

                labelText:
                    'Email Address',

                border:
                    OutlineInputBorder(),

                prefixIcon:
                    Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 16),

            // ================= FULL NAME =================

            TextField(

              controller:
                  fullNameController,

              decoration:
                  const InputDecoration(

                labelText:
                    'Full Name',

                border:
                    OutlineInputBorder(),

                prefixIcon:
                    Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 16),

            // ================= PASSWORD =================

            TextField(

              controller:
                  passwordController,

              obscureText:
                  _obscurePassword,

              onChanged: (_) {

                setState(() {});
              },

              decoration:
                  InputDecoration(

                labelText:
                    'Password',

                border:
                    const OutlineInputBorder(),

                prefixIcon:
                    const Icon(Icons.lock_outline),

                suffixIcon:
                    IconButton(

                  icon: Icon(

                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),

                  onPressed: () {

                    setState(() {

                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= CONFIRM PASSWORD =================

            TextField(

              controller:
                  confirmPasswordController,

              obscureText:
                  _obscureConfirm,

              onChanged: (_) {

                setState(() {});
              },

              decoration:
                  InputDecoration(

                labelText:
                    'Confirm Password',

                border:
                    const OutlineInputBorder(),

                prefixIcon:
                    const Icon(Icons.lock_outline),

                suffixIcon:
                    IconButton(

                  icon: Icon(

                    _obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),

                  onPressed: () {

                    setState(() {

                      _obscureConfirm =
                          !_obscureConfirm;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ================= PASSWORD MATCH =================

            if (confirmPasswordController
                .text
                .isNotEmpty)

              Row(

                children: [

                  Icon(

                    passwordController.text ==
                            confirmPasswordController
                                .text

                        ? Icons.check_circle

                        : Icons.cancel,

                    size: 16,

                    color:
                        passwordController.text ==
                                confirmPasswordController
                                    .text

                            ? Colors.green

                            : Colors.red,
                  ),

                  const SizedBox(width: 6),

                  Text(

                    passwordController.text ==
                            confirmPasswordController
                                .text

                        ? "Passwords match"

                        : "Passwords do not match",

                    style: TextStyle(

                      color:
                          passwordController.text ==
                                  confirmPasswordController
                                      .text

                              ? Colors.green

                              : Colors.red,

                      fontSize: 13,
                    ),
                  ),
                ],
              ),

            // ================= ERROR MESSAGE =================

            if (_errorMessage != null) ...[

              const SizedBox(height: 10),

              Container(

                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(

                  color:
                      Colors.red.shade50,

                  borderRadius:
                      BorderRadius.circular(8),

                  border: Border.all(
                    color:
                        Colors.red.shade200,
                  ),
                ),

                child: Row(

                  children: [

                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Expanded(

                      child: Text(

                        _errorMessage!,

                        style:
                            const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ================= CREATE BUTTON =================

            Padding(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 40,
              ),

              child: ElevatedButton(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.black,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
                  ),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                onPressed:
                    _isLoading
                        ? null
                        : _createAccount,

                child:
                    _isLoading

                        ? const SizedBox(

                            height: 22,

                            width: 22,

                            child:
                                CircularProgressIndicator(

                              color: Colors.white,

                              strokeWidth: 2.5,
                            ),
                          )

                        : const Text(

                            'Create Account',

                            style: TextStyle(

                              fontSize: 18,

                              color: Colors.white,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}