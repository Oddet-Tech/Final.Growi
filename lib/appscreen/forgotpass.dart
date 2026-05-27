import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {

  // ================= CONTROLLER =================

  final TextEditingController emailController =
      TextEditingController();

  // ================= FIREBASE =================

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ================= VARIABLES =================

  bool _isLoading = false;

  String? _message;

  // ================= RESET PASSWORD =================

  Future<void> _resetPassword() async {

    final email =
        emailController.text.trim();

    // ================= VALIDATION =================

    if (email.isEmpty ||
        !email.contains('@')) {

      setState(() {

        _message =
            "Please enter a valid email address.";
      });

      return;
    }

    setState(() {

      _isLoading = true;

      _message = null;
    });

    try {

      // ================= SEND RESET EMAIL =================

      await _auth.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      setState(() {

        _message =
            "Password reset email sent to:\n$email";
      });

      // ================= SUCCESS SNACKBAR =================

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor: Colors.green,

          content: Text(
            "Reset email sent successfully.",
          ),
        ),
      );

    }

    // ================= FIREBASE ERRORS =================

    on FirebaseAuthException catch (e) {

      String errorMessage;

      switch (e.code) {

        case 'user-not-found':
          errorMessage =
              "No account found with this email.";
          break;

        case 'invalid-email':
          errorMessage =
              "Invalid email address.";
          break;

        default:
          errorMessage =
              e.message ??
              "Something went wrong.";
      }

      setState(() {

        _message = errorMessage;
      });
    }

    // ================= OTHER ERRORS =================

    catch (e) {

      setState(() {

        _message =
            "Unexpected Error: $e";
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

  // ================= DISPOSE =================

  @override
  void dispose() {

    emailController.dispose();

    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8EED2),

      body: Center(

        child: ListView(

          children: [

            // ================= LOGO =================

            SizedBox(

              child: ListTile(

                contentPadding:
                    const EdgeInsets.only(
                  left: 10,
                  top: 100,
                  bottom: 10,
                ),

                title: Image.asset(

                  'assets/Icon.png',

                  width: 150,

                  height: 150,
                ),
              ),
            ),

            // ================= TITLE =================

            const Padding(

              padding: EdgeInsets.only(
                left: 170,
                right: 170,
                bottom: 20,
                top: 8,
              ),

              child: Text(

                'Forgot Password',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
            ),

            // ================= EMAIL FIELD =================

            Padding(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: TextField(

                controller:
                    emailController,

                keyboardType:
                    TextInputType.emailAddress,

                decoration:
                    const InputDecoration(

                  labelText:
                      'Enter Email',

                  border:
                      OutlineInputBorder(),

                  prefixIcon:
                      Icon(Icons.email_outlined),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= RESET BUTTON =================

            Padding(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 80,
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
                        : _resetPassword,

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

                            'Reset Password',

                            style: TextStyle(

                              fontSize: 18,

                              color: Colors.white,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
              ),
            ),

            // ================= MESSAGE =================

            if (_message != null) ...[

              const SizedBox(height: 20),

              Padding(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                ),

                child: Container(

                  padding:
                      const EdgeInsets.all(12),

                  decoration: BoxDecoration(

                    color:
                        Colors.white,

                    borderRadius:
                        BorderRadius.circular(10),

                    border: Border.all(
                      color: Colors.black12,
                    ),
                  ),

                  child: Text(

                    _message!,

                    textAlign:
                        TextAlign.center,

                    style: TextStyle(

                      color:
                          _message!
                                  .contains(
                                      "sent")
                              ? Colors.green
                              : Colors.red,

                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}