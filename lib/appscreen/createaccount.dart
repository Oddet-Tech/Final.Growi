import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growi_project/services/auth_service.dart';
import 'package:growi_project/appscreen/realappscreen.dart';

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

  // ================= VARIABLES =================

  bool _isLoading = false;

  bool _obscurePassword = true;

  bool _obscureConfirm = true;
  Timer? _verificationTimer;
  bool _verificationComplete = false;

  String? _errorMessage;

  String? _infoMessage;

  // ================= DISPOSE =================

  @override
  void dispose() {

    _verificationTimer?.cancel();

    fullNameController.dispose();

    emailController.dispose();

    passwordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();
  }

  void _watchForVerification(User user, String fallbackName, String email) {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkEmailVerification(user, fallbackName, email),
    );
  }

  Future<void> _checkEmailVerification(
    User user,
    String fallbackName,
    String email,
  ) async {
    try {
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser == null || !refreshedUser.emailVerified || _verificationComplete) {
        return;
      }

      _verificationComplete = true;
      _verificationTimer?.cancel();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => RealHome(
            name: refreshedUser.displayName ?? fallbackName,
            email: refreshedUser.email ?? email,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Email verification check error: $e');
    }
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

    final emailIsValid = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(email);

    if (fullName.isEmpty ||
        !emailIsValid ||
        password.isEmpty ||
        confirmPassword.isEmpty) {

      setState(() {
        _errorMessage = !emailIsValid
            ? "Please enter a valid email address."
            : "Please fill in all fields.";
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
      _infoMessage =
          'Creating your account... A verification email will be sent to $email.\nPlease check your inbox and spam folder.';
    });

    try {
      // ================= CREATE USER =================

      final UserCredential credential =
          await AuthService.createAccount(
        email: email,
        password: password,
        fullName: fullName,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception(
          "Account creation failed.",
        );
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _infoMessage = "we've sent you an Email for Verification";
      });

      _watchForVerification(user, fullName, email);

      // ================= SUCCESS MESSAGE =================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          content: Text(
            "we've sent you an Email for Verification\n$email",
          ),
        ),
      );

      // ================= RETURN TO LOGIN =================

      // Keep the user on the verification message screen
      // so they can see the email instructions clearly.
    }

    // ================= FIREBASE ERRORS =================

    on FirebaseAuthException catch (e) {

      final message = AuthService.getFriendlyError(e);

      setState(() {
        _errorMessage = message;
        _infoMessage = null;
      });
    }

    // ================= OTHER ERRORS =================

    catch (e) {

      setState(() {
        _errorMessage =
            "Unexpected error: $e";
        _infoMessage = null;
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
                    passwordController.text ==confirmPasswordController.text
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
            if (_infoMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _infoMessage!,
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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