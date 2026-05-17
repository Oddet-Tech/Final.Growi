import 'package:flutter/material.dart';
import 'package:growi_project/admin.dart';
import 'package:growi_project/appscreen/payment.dart';
import 'package:growi_project/appscreen/models.dart';
import 'dart:io';

class UserPurchase extends StatefulWidget {
  const UserPurchase({super.key});

  @override
  State<UserPurchase> createState() => _UserPurchaseState();
}

class _UserPurchaseState extends State<UserPurchase> {

  final List<Map<String, dynamic>> cart = [];
  final Map<int, String> selectedColors = {};

  bool showCart = false;
  int totalPrice = 0;

  String pickupMethod = "PEP";
  String? selectedStore;
  final TextEditingController customLocation = TextEditingController();

  final List<String> pepStores = [
    "PEP - East London CBD",
    "PEP - Hemingways Mall",
    "PEP - Mdantsane City",
    "PEP - Beacon Bay",
  ];

  int get cartCount => cart.length;

  // 🔥 IMAGE VIEW
  void openImage(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(File(path)),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 ADD TO CART
  void addToCart(Models phone, int index) {

    final color = selectedColors[index];

    if (color == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a color")),
      );
      return;
    }

    setState(() {
      cart.add({
        "item": phone,
        "color": color,
      });

      totalPrice += phone.price;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${phone.name} added ($color)"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // 🔥 REMOVE
  void removeFromCart(int i) {
    setState(() {
      totalPrice -= (cart[i]["item"] as Models).price;
      cart.removeAt(i);
    });
  }

  // 🔥 CHECKOUT (CLEAN + SAFE)
  void checkout() {

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return;
    }

    String pickup = "";

    if (pickupMethod == "PEP") {
      pickup = selectedStore ?? customLocation.text;
    } else {
      pickup = customLocation.text;
    }

    if (pickup.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter pickup location")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          cartItems: cart.map((e) => e["item"] as Models).toList(),
          totalPrice: totalPrice,
          pickupLocation: pickup,

          // 🔥 THEME FIXED (SAFE)
          themeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // 🔥 SHOP
  Widget buildShop() {

    if (globalPhonesList.isEmpty) {
      return const Center(child: Text("No phones"));
    }

    return ListView.builder(
      itemCount: globalPhonesList.length,
      itemBuilder: (_, i) {

        final phone = globalPhonesList[i];

        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (phone.imagePath != null)
                SizedBox(
                  height: 200,
                  child: PageView(
                    children: phone.imagePath!
                        .map((img) => GestureDetector(
                              onTap: () => openImage(img),
                              child: Image.file(File(img), fit: BoxFit.cover),
                            ))
                        .toList(),
                  ),
                ),

              ListTile(
                title: Text(phone.name),
                subtitle: Text(phone.description),
              ),

              if (phone.colors.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    children: phone.colors.map((color) {

                      final selected = selectedColors[i] == color;

                      return ChoiceChip(
                        label: Text(color),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            selectedColors[i] = color;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "R${(phone.price * 1.04).toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () => addToCart(phone, i),
                      child: const Text("Add"),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // 🔥 CART
  Widget buildCart() {

    if (cart.isEmpty) {
      return const Center(child: Text("Cart empty"));
    }

    return Column(
      children: [

        Expanded(
          child: ListView.builder(
            itemCount: cart.length,
            itemBuilder: (_, i) {

              final phone = cart[i]["item"] as Models;
              final color = cart[i]["color"];

              return ListTile(
                title: Text(phone.name),
                subtitle: Text("Color: $color"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => removeFromCart(i),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: checkout,
              child: const Text("Checkout"),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Store"),

        actions: [

          Stack(
            children: [

              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => setState(() => showCart = !showCart),
              ),

              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: showCart ? buildCart() : buildShop(),
    );
  }
}