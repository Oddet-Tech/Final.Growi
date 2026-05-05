import 'package:flutter/material.dart';
import 'package:growi_project/appscreen/payment.dart';
import 'appscreen/models.dart';
import 'admin.dart';


class UserPurchase extends StatefulWidget {
  const UserPurchase({super.key});

  @override
  State<UserPurchase> createState() => _UserPurchaseState();
}

class _UserPurchaseState extends State<UserPurchase> {
  final List<Models> purchaseCart = [];
  bool _showCart = false;
  int _totalPrice = 0;

  void _addToCart(Models phone) {
    setState(() {
      purchaseCart.add(phone);
      _totalPrice += phone.price;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${phone.name} added to cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _totalPrice -= purchaseCart[index].price;
      purchaseCart.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _checkout() {
    if (purchaseCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          cartItems: purchaseCart,
          totalPrice: _totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Store'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  setState(() {
                    _showCart = !_showCart;
                  });
                },
              ),
              if (purchaseCart.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${purchaseCart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: _showCart ? _buildCartView() : _buildShopView(),
    );
  }

  Widget _buildShopView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: globalPhonesList.length,
      itemBuilder: (context, index) {
        final phone = globalPhonesList[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(phone.name),
            subtitle: Text(phone.description),
            trailing: ElevatedButton(
              onPressed: () => _addToCart(phone),
              child: const Text("Add"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartView() {
    return purchaseCart.isEmpty
        ? const Center(child: Text("Cart is empty"))
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: purchaseCart.length,
                  itemBuilder: (context, index) {
                    final item = purchaseCart[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text("R${item.price * 1.04}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFromCart(index),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: purchaseCart.isEmpty ? null : _checkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Proceed to Checkout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}