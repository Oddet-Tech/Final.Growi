import 'package:flutter/material.dart';
import 'appscreen/models.dart';
import 'dart:io';

// 🔥 GLOBAL ORDER HISTORY (ADMIN WILL UPDATE STATUS)
List<Map<String, dynamic>> globalPurchaseHistory = [];

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: globalPurchaseHistory.isEmpty
          ? _buildEmptyState()
          : _buildPurchaseHistory(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No purchases yet',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your purchase history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // 🔥 STATUS BADGE (IMPORTANT FOR ADMIN CONTROL)
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "Shipped":
        color = Colors.green;
        break;
      case "Pending":
      default:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPurchaseHistory() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Purchase History',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ...globalPurchaseHistory.map((purchase) {
          final items = purchase['items'] as List<Models>;
          final totalPrice = purchase['totalPrice'] as int;
          final purchaseDate = purchase['date'] as DateTime;
          final status = purchase['status'] ?? "Pending";
          final pickup = purchase['pickup'] ?? "Not set";

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔥 HEADER + STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${globalPurchaseHistory.indexOf(purchase) + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      _statusBadge(status),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Pickup: $pickup",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [

                            if (item.imagePath != null)
                              Container(
                                width: 45,
                                height: 45,
                                margin: const EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    File(item.imagePath! as String),
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.phone_android),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 45,
                                height: 45,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.phone_android),
                              ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "R${item.price}",
                                    style: TextStyle(
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),

                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'R$totalPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}