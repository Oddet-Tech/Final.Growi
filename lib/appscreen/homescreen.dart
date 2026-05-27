import 'package:flutter/material.dart';
import 'package:growi_project/appscreen/Login.dart';
import 'package:growi_project/appscreen/createaccount.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the icon so it is guaranteed to be ready
    // on the very first frame — no pop-in, no placeholder needed.
    precacheImage(const AssetImage('assets/Icon.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EED2),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo — renders instantly with the rest of the page
              Image.asset(
                'assets/Icon.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 40),

              // Login button
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 140,
                  maxWidth: 250,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SecondScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 230, 228, 185),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sign up
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewAccountScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 11, 199, 42),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}