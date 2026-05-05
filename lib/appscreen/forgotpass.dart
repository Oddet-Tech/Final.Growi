import 'package:flutter/material.dart';

class ForgotPass extends StatelessWidget {
  const ForgotPass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EED2),
      body: Center(
        child: ListView(
          children: [
            SizedBox(
              child: ListTile(
                contentPadding: const EdgeInsets.only(left:10,top: 100,bottom: 10),
                title: Image.asset(
                  'assets/Icon.png',
                  width: 150,
                  height: 150,
                ),//this image is in the assets folder
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 170,right: 170,bottom: 20,top:8),
              child: Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Enter Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
