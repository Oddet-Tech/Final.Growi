import 'dart:io';
import 'package:flutter/material.dart';
import 'package:growi_project/admin.dart';
import 'package:geolocator/geolocator.dart';
import 'models.dart';



class PaymentPage extends StatefulWidget {
  final List<Models> cartItems;
  final int totalPrice;
  final dynamic pickupLocation;

  const PaymentPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.pickupLocation,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  final _formKey = GlobalKey<FormState>();

  // 🔥 PICKUP
  String _pickupType = "PEP";
  String? _selectedPEP;
  String? _selectedPostNet;

  final TextEditingController _customLocation =
      TextEditingController();

  String? _liveLocation;

  final List<String> pepStores = [
    "PEP - East London CBD",
    "PEP - Hemingways Mall",
    "PEP - Mdantsane City",
    "PEP - Beacon Bay",
  ];

  final List<String> postNetStores = [
    "PostNet - Vincent",
    "PostNet - Beacon Bay",
    "PostNet - Hemingways",
    "PostNet - East London CBD",
  ];

  // 🔥 EFT
  final TextEditingController _holder = TextEditingController();
  final TextEditingController _card = TextEditingController();
  final TextEditingController _expiry = TextEditingController();
  final TextEditingController _cvv = TextEditingController();

  bool _saveCard = true;

  double get total => widget.totalPrice * 1.04;
  
  get Geolocator => null;

  // 🔥 REAL LOCATION (MR D STYLE)
  Future<void> _locateMe() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enable location services")),
      );
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position pos = await Geolocator.getCurrentPosition();

    setState(() {
      _liveLocation =
          "Lat: ${pos.latitude}, Lng: ${pos.longitude}";
    });
  }

  // 🔥 PLACE ORDER (FIXED STRUCTURE)
  void _placeOrder() {

    if (!_formKey.currentState!.validate()) return;

    String pickup;

    if (_pickupType == "PEP") {
      if (_selectedPEP == null) return;
      pickup = _selectedPEP!;
    } else if (_pickupType == "PostNet") {
      if (_selectedPostNet == null) return;
      pickup = _selectedPostNet!;
    } else {
      pickup = _liveLocation ?? _customLocation.text;
    }

    orders.add({
      "items": widget.cartItems.map((item) => {
        "name": item.name,
        "description": item.description,
        "price": item.price,
        "colors": item.colors,
        "image": item.imagePath,
      }).toList(),

      "total": total,
      "pickup": pickup,
      "type": _pickupType,
      "status": "Pending",

      "payment": {
        "method": "EFT",
        "holder": _holder.text,
        "card": _card.text,
        "expiry": _expiry.text,
        "save": _saveCard,
      },
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Order Successful"),
        content: Text("Pickup: $pickup"),
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
  }

  // 🔥 ORDER ITEMS (WITH COLORS SHOWN)
  Widget _items() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Items",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...widget.cartItems.map((item) => Card(
          child: ListTile(
            leading: item.imagePath != null && item.imagePath!.isNotEmpty
                ? Image.file(File(item.imagePath!.first), width: 50)
                : const Icon(Icons.phone),

            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description),
                Wrap(
                  spacing: 6,
                  children: item.colors
                      .map((c) => Chip(label: Text(c)))
                      .toList(),
                )
              ],
            ),
            trailing: Text("R${item.price}"),
          ),
        )),
      ],
    );
  }

  // 🔥 PICKUP SECTION (FIXED)
  Widget _pickup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("Pickup Method",
            style: TextStyle(fontWeight: FontWeight.bold)),

        RadioListTile(
          value: "PEP",
          groupValue: _pickupType,
          onChanged: (v) => setState(() => _pickupType = v!),
          title: const Text("PEP"),
        ),

        if (_pickupType == "PEP")
          DropdownButtonFormField<String>(
            value: _selectedPEP,
            items: pepStores
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _selectedPEP = v),
          ),

        RadioListTile(
          value: "PostNet",
          groupValue: _pickupType,
          onChanged: (v) => setState(() => _pickupType = v!),
          title: const Text("PostNet"),
        ),

        if (_pickupType == "PostNet")
          DropdownButtonFormField<String>(
            value: _selectedPostNet,
            items: postNetStores
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _selectedPostNet = v),
          ),

        RadioListTile(
          value: "Location",
          groupValue: _pickupType,
          onChanged: (v) => setState(() => _pickupType = v!),
          title: const Text("Use My Location"),
        ),

        if (_pickupType == "Location") ...[
          Text(_liveLocation ?? "No location yet"),

          ElevatedButton.icon(
            onPressed: _locateMe,
            icon: const Icon(Icons.my_location),
            label: const Text("Locate Me"),
          ),
        ],
      ],
    );
  }

  // 🔥 PAYMENT
  Widget _payment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text("EFT Payment",
            style: TextStyle(fontWeight: FontWeight.bold)),

        TextField(controller: _holder, decoration: const InputDecoration(labelText: "Account Holder")),
        TextField(controller: _card, decoration: const InputDecoration(labelText: "Card Number")),
        TextField(controller: _expiry, decoration: const InputDecoration(labelText: "Expiry")),
        TextField(controller: _cvv, decoration: const InputDecoration(labelText: "CVV")),

        CheckboxListTile(
          value: _saveCard,
          onChanged: (v) => setState(() => _saveCard = v!),
          title: const Text("Save Card"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              _items(),
              const SizedBox(height: 20),

              _pickup(),
              const SizedBox(height: 20),

              _payment(),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total"),
                  Text("R${total.toStringAsFixed(2)}"),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _placeOrder,
                child: const Text("Place Order"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}