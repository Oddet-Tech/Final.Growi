import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:growi_project/admin.dart';
import 'package:growi_project/appscreen/models.dart';
import 'package:growi_project/appscreen/payment.dart';

class UserPurchese extends StatefulWidget {
  const UserPurchese({super.key});

  @override
  State<UserPurchese> createState() => _UserPurcheseState();
}

class _UserPurcheseState extends State<UserPurchese> {
  final List<Map<String, dynamic>> cart = [];

  final Map<int, String> selectedColors = {};

  bool showCart = false;

  double totalPrice = 0;

  // ================= ADD TO CART =================

  void addToCart(Models product, int index) {
    final color = selectedColors[index];

    if (color == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a color")));
      return;
    }

    if (!product.inStock || product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This product is sold out"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      cart.add({"item": product, "color": color});

      totalPrice += product.price;
      product.stockQuantity -= 1;

      if (product.stockQuantity <= 0) {
        product.inStock = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text("${product.name} added ($color)"),
      ),
    );
  }

  // ================= REMOVE =================

  void removeFromCart(int i) {
    setState(() {
      final item = cart[i]['item'] as Models;

      totalPrice -= item.price;

      item.stockQuantity += 1;
      item.inStock = true;

      cart.removeAt(i);
    });
  }

  // ================= IMAGE VIEW =================

  Future<void> openImage(dynamic img) async {
    Widget imageWidget;

    if (img is Uint8List) {
      imageWidget = Image.memory(
        img,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              'Unable to display image',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } else if (img is String) {
      imageWidget = Image.network(
        img,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              'Unable to display image',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } else {
      imageWidget = const Center(
        child: Text(
          'Unable to display image',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(child: InteractiveViewer(child: imageWidget)),
        ),
      ),
    );
  }

  // ================= CHECKOUT =================

  void checkout() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cart is empty")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          cartItems: cart.map((e) => e['item'] as Models).toList(),
          totalPrice: totalPrice,
          pickupLocation: "PEP",
          themeColor: const Color(0xFF1F7A4C),
        ),
      ),
    );
  }

  // ================= SHOP =================

  Widget buildShop() {
    if (globalPhonesList.isEmpty) {
      return const Center(
        child: Text("No Products Available", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: globalPhonesList.length,
      itemBuilder: (_, i) {
        final product = globalPhonesList[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= PRODUCT IMAGES =================
              if (product.webImages != null && product.webImages!.isNotEmpty)
                Stack(
                  children: [
                    SizedBox(
                      height: 240,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: PageView.builder(
                          itemCount: product.webImages!.length,
                          itemBuilder: (_, imgIndex) {
                            final img = product.webImages![imgIndex];

                            return GestureDetector(
                              onTap: () => openImage(img),
                              child: Image.memory(
                                img,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // SOLD OUT BANNER
                    if (!product.inStock)
                      Positioned(
                        top: 18,
                        left: -40,
                        child: Transform.rotate(
                          angle: -0.7,
                          child: Container(
                            width: 180,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: Colors.red,
                            child: const Center(
                              child: Text(
                                "SOLD OUT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= NAME =================
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ================= DESCRIPTION =================
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ================= REMAINING =================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            color: Color(0xFF1F7A4C),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Remaining: ${product.stockQuantity}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F7A4C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ================= COLORS =================
                    if (product.colors.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.colors.map((color) {
                          final selected = selectedColors[i] == color;

                          return ChoiceChip(
                            selectedColor: Colors.green.shade200,
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

                    const SizedBox(height: 20),

                    // ================= PRICE + ADD =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "R${product.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Color(0xFF1F7A4C),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F7A4C),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: product.inStock
                              ? () => addToCart(product, i)
                              : null,
                          icon: const Icon(Icons.shopping_cart),
                          label: Text(product.inStock ? "Add" : "Sold Out"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= CART =================

  Widget buildCart() {
    if (cart.isEmpty) {
      return const Center(
        child: Text("Cart Empty", style: TextStyle(fontSize: 20)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cart.length,
            itemBuilder: (_, i) {
              final phone = cart[i]['item'] as Models;
              final color = cart[i]['color'];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  minLeadingWidth: 60,
                  contentPadding: const EdgeInsets.all(14),
                  leading:
                      phone.webImages != null && phone.webImages!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            phone.webImages!.first,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.phone_android),
                  title: Text(
                    phone.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Color: $color"),
                      Text("R${phone.price.toStringAsFixed(2)}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeFromCart(i),
                  ),
                ),
              );
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "R$totalPrice",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F7A4C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F7A4C),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: checkout,
                  child: const Text("Checkout", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EED2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "iSupply Store",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      showCart = !showCart;
                    });
                  },
                ),

                // ================= SMALL CART BADGE =================
                if (cart.isNotEmpty)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cart.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: showCart ? buildCart() : buildShop(),
    );
  }
}
