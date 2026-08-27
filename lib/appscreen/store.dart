import 'package:flutter/material.dart';
import 'package:growi_project/admin.dart';

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
                    builder: (context) => const UserPurchase(),
                  ),
                );
              },
             child: Container(
  height: 100,
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFFF9EFE6), // Cream background
    border: Border.all(
      width: 2,
      color: Colors.black,
    ),
    borderRadius: BorderRadius.circular(12),
    image: const DecorationImage(
      image: AssetImage('assets/Clothing.png'),
      fit: BoxFit.contain,
      alignment: Alignment.center,
      opacity: 1.0,
    ),
  ),
  child: const Row(
    children: [
      Icon(Icons.shopping_bag, size: 40),
      SizedBox(width: 12),
      Text(
        'Growi Dress',
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
              onTap: () {},
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/sneeker.png'),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    opacity: 0.35,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shop, size: 40),
                    SizedBox(width: 12),
                    Text(
                      'Growi Device',
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
