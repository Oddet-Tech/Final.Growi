
import 'package:flutter/material.dart';

class Tickets extends StatelessWidget {
  const Tickets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          /// FIRST CONTAINER
         GestureDetector(
  onTap: () {
  },
  child: Container(
    width: double.infinity,
    height: 170,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all( Radius.circular(12)),
      border: Border.all(
        color: Colors.black,
        width: 2,
      ),
      image: const DecorationImage(
        image: AssetImage('assets/ticket.png'),
        fit: BoxFit.cover,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.confirmation_number_outlined,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 8),
          Text(
            'Event tickets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 4,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
      ],
      ),);
  }
}