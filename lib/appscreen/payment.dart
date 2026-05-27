import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growi_project/services/firebase_service.dart';
import 'models.dart';

class PaymentPage extends StatefulWidget {
  final List<Models> cartItems;
  final double totalPrice;
  final String pickupLocation;
  final Color themeColor;

  const PaymentPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.pickupLocation,
    required this.themeColor,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController pepLocationController = TextEditingController();
  final TextEditingController postNetLocationController =TextEditingController();
  final TextEditingController cardHolder = TextEditingController();
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController expiryDate = TextEditingController();
  final TextEditingController cvv = TextEditingController();

  bool processingPayment = false;
  bool locationLoading = true;

  Position? userLocation;

  String locationAddress = "Getting location...";

  String deliveryType = "PEP";

  double get taxAmount => widget.totalPrice * 0.08;

  double get finalTotal => widget.totalPrice + taxAmount;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }
  // ================= LOCATION =================
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        locationAddress = "Location permission denied";
        locationLoading = false;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLocation = position;
        locationAddress =
            "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        locationLoading = false;
      });
    } catch (e) {
      setState(() {
        locationAddress = "Failed to get location";
        locationLoading = false;
      });
    }
  }

  // ================= PAYMENT =================

  Future<void> processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      processingPayment = true;
    });

    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please sign in before checking out.")),
        );
        setState(() {
          processingPayment = false;
        });
        return;
      }

      final userEmail = currentUser.email ?? "";

      final userName = currentUser.displayName ?? "Customer";

      final orderItems = widget.cartItems
          .map(
            (item) => OrderItem.fromModel(
              item,
              item.colors.isNotEmpty ? item.colors.first : "Default",
            ),
          )
          .toList();

      final digits = cardNumber.text.replaceAll(" ", "");

      final last4 = digits.length >= 4
          ? digits.substring(digits.length - 4)
          : digits;

      final paymentInfo = PaymentInfo(
        cardHolder: cardHolder.text.trim(),
        cardNumber: "**** **** **** $last4",
        expiryDate: expiryDate.text,
        cvv: "***",
      );

      final selectedStore = deliveryType == "PEP"
          ? pepLocationController.text
          : postNetLocationController.text;

      final locationInfo = LocationInfo(
        latitude: userLocation?.latitude ?? 0,
        longitude: userLocation?.longitude ?? 0,
        address: locationAddress,
        storeName: selectedStore,
        storeType: deliveryType,
      );

      final order = Order(
        id: '',
        userId: currentUser.uid,
        items: orderItems,
        totalAmount: widget.totalPrice,
        taxAmount: taxAmount,
        finalTotal: finalTotal,
        paymentInfo: paymentInfo,
        locationInfo: locationInfo,
        status: 'Pending',
        orderDate: DateTime.now(),
      );

      final orderId = await FirebaseService.createOrder(order);

      await FirebaseService.sendOrderConfirmationEmail(
        order,
        userEmail,
        userName,
      );

      setState(() {
        processingPayment = false;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Payment Successful"),
          content: Text("Order ID: $orderId"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        processingPayment = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ================= ITEMS =================

  Widget buildItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selected Items",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        ...widget.cartItems.map((item) {
          Uint8List? image;

          if (item.webImages != null && item.webImages!.isNotEmpty) {
            image = item.webImages!.first;
          }

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: image != null
                    ? Image.memory(
                        image,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ),
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item.colors.isNotEmpty
                        ? "Color: ${item.colors.first}"
                        : "Default Color",
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Text(
                "R${item.price.toStringAsFixed(2)}",
                style: TextStyle(
                  color: widget.themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ================= LOCATION =================

  Widget buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Location",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                locationLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.location_on, color: Colors.blue.shade700),

                const SizedBox(width: 12),

                Expanded(child: Text(locationAddress)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DELIVERY =================

  Widget buildDeliverySection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pickup Location",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          RadioListTile<String>(
            value: "PEP",
            groupValue: deliveryType,
            activeColor: widget.themeColor,
            title: const Text("PEP Store"),
            onChanged: (value) {
              setState(() {
                deliveryType = value!;
              });
            },
          ),

          if (deliveryType == "PEP")
            TextFormField(
              controller: pepLocationController,
              decoration: const InputDecoration(
                labelText: "Enter PEP Location",
                hintText: "e.g PEP Beacon Bay",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (v) {
                if (deliveryType == "PEP" && (v == null || v.isEmpty)) {
                  return "Enter PEP location";
                }
                return null;
              },
            ),

          const SizedBox(height: 10),

          RadioListTile<String>(
            value: "POSTNET",
            groupValue: deliveryType,
            activeColor: widget.themeColor,
            title: const Text("POSTNET Store"),
            onChanged: (value) {
              setState(() {
                deliveryType = value!;
              });
            },
          ),

          if (deliveryType == "POSTNET")
            TextFormField(
              controller: postNetLocationController,
              decoration: const InputDecoration(
                labelText: "Enter POSTNET Location",
                hintText: "e.g POSTNET Vincent",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (v) {
                if (deliveryType == "POSTNET" && (v == null || v.isEmpty)) {
                  return "Enter POSTNET location";
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  // ================= CARD FORM =================

  Widget buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Card Information",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: cardHolder,
            decoration: const InputDecoration(
              labelText: "Card Holder",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Required";
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: cardNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: "Card Number",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: (v) {
              if (v == null || v.length < 16) {
                return "Invalid card";
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: expiryDate,
                  decoration: const InputDecoration(
                    labelText: "MM/YY",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: TextFormField(
                  controller: cvv,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "CVV",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 3) {
                      return "Invalid";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EED2),

      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        title: const Text("Dropoff & Payment"),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SafeArea(
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: processingPayment ? null : processPayment,
              child: processingPayment
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Checkout • R${finalTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildItems(),

              const SizedBox(height: 20),

              buildLocationSection(),

              const SizedBox(height: 20),

              buildDeliverySection(),

              const SizedBox(height: 20),

              buildPaymentForm(),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
