
import 'package:flutter/material.dart';
import 'package:growi_project/Userpurchase.dart';

class IStoreScreen extends StatelessWidget {
  const IStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
           
            GestureDetector(
                onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>UserPurchase(),
      ),
    );
  },
       child: Container(
  height: 100,
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(width: 2, color: Colors.black),
    borderRadius: BorderRadius.circular(12),
    image: const DecorationImage(
      image: AssetImage('assets/iphone.webp'),
      fit: BoxFit.contain, 
      alignment: Alignment.center, 
      opacity: 0.30,
    ),
  ),
  child: Row(
    children: const [
      Icon(Icons.phone_iphone, size: 40),
      SizedBox(width: 12),
      Text(
        'ISupply',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
            ),
            GestureDetector(
              onTap: () {
              
              },
       child: Container(
  height: 100,
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(width: 2, color: Colors.black),
    borderRadius: BorderRadius.circular(12),
    image: const DecorationImage(
      image: AssetImage('Assets/sneeker.png'),
      fit: BoxFit.contain, 
      alignment: Alignment.center, 
      opacity: 0.35,
    ),
  ),
  child: Row(
    children: const [
      Icon(Icons.shop, size: 40),
      SizedBox(width: 12),
      Text(
        'Shoe Store',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
            ),
          ],
        ),
      ),
    );
  }
}
