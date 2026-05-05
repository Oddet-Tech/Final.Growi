import 'package:flutter/material.dart';

class NewAccountScreen extends StatefulWidget {
  const NewAccountScreen({super.key});

  @override
  State<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController opt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Account',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        backgroundColor: const Color(0xFFF8EED2),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Enter Full Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16.0),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 16.0),

            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
   const SizedBox(height: 16.0),

            TextField(
              controller: opt,
              decoration: const InputDecoration(
                labelText: 'Enter OTP sent to your email',
                border: OutlineInputBorder(),
              ),
            ),
       if(passwordController.text != confirmPasswordController.text)
              const Text(
                'Passwords do not match',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),

            Padding(
              padding: const EdgeInsets.only(left: 150, right: 150),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'Create',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
