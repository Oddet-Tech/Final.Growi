import 'package:flutter/material.dart';
import 'appscreen/models.dart';
import 'package:image_picker/image_picker.dart';

// GLOBAL DATA
List<Models> globalPhonesList = [];
List<Map<String, dynamic>> orders = [];

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final picker = ImagePicker();

  int _selectedTab = 0;

  final TextEditingController name = TextEditingController();
  final TextEditingController desc = TextEditingController();
  final TextEditingController price = TextEditingController();

  List<String> selectedImages = [];
  Set<String> selectedColors = {};

  final List<String> phoneColors = [
    "Black","White","Silver","Gold","Blue","Red",
    "Green","Purple","Pink","Gray","Titanium",
  ];

  double get pendingSales =>
      orders.fold(0, (sum, o) => sum + (o['total'] ?? 0));

  double get estimatedSales =>
      globalPhonesList.fold(0, (sum, p) => sum + p.price);

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        selectedImages = picked.map((e) => e.path).toList();
      });
    }
  }

  void addPhone() {
    if (name.text.isEmpty || desc.text.isEmpty || price.text.isEmpty) return;

    globalPhonesList.add(
      Models(
        name: name.text,
        description: desc.text,
        price: int.parse(price.text),
        imagePath: selectedImages,
        colors: selectedColors.toList(),
      ),
    );

    setState(() {
      name.clear();
      desc.clear();
      price.clear();
      selectedImages.clear();
      selectedColors.clear();
    });
  }

  void updateStatus(int i, String status) {
    setState(() => orders[i]['status'] = status);
  }

  // 🔥 STATUS BADGE
  Widget statusBadge(String status) {
    Color color = status == "Shipped"
        ? Colors.green
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),

      body: Column(
        children: [

          // 🔥 TABS
          Container(
            color: Colors.black,
            child: Row(
              children: [
                _tab("Listing", 0),
                _tab("Pending", 1),
                _tab("Orders", 2),
              ],
            ),
          ),

          // 🔥 SALES HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey[900],
            child: Column(
              children: [
                const Text("Estimated Sales",
                    style: TextStyle(color: Colors.white70)),

                Text("R$estimatedSales",
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Expanded(
            child: _selectedTab == 0
                ? _listing()
                : _selectedTab == 1
                    ? _pendingView()
                    : _orders(),
          ),
        ],
      ),
    );
  }

  Widget _tab(String t, int i) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = i),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: _selectedTab == i ? Colors.green : Colors.black,
          child: Center(
            child: Text(t, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // 🔥 LISTING (UNCHANGED BUT CLEAN)
  Widget _listing() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
        TextField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
        TextField(controller: price, decoration: const InputDecoration(labelText: "Price")),

        const SizedBox(height: 10),

        ElevatedButton(onPressed: pickImages, child: const Text("Pick Images")),

        Wrap(
          spacing: 10,
          children: phoneColors.map((c) {
            final selected = selectedColors.contains(c);
            return FilterChip(
              label: Text(c),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  v ? selectedColors.add(c) : selectedColors.remove(c);
                });
              },
            );
          }).toList(),
        ),

        ElevatedButton(
          onPressed: addPhone,
          child: const Text("Add Phone"),
        ),
      ],
    );
  }

  // 🔥 PENDING VIEW (NEW REQUEST IMPLEMENTATION)
  Widget _pendingView() {
    final pendingOrders =
        orders.where((o) => o['status'] == "Pending").toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [

        Text(
          "Pending Amount: R$pendingSales",
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...pendingOrders.map((o) => Card(
              elevation: 4,
              child: ListTile(
                title: Text("Order ${orders.indexOf(o) + 1}"),
                subtitle: Text(o['pickup'] ?? ""),
                trailing: statusBadge(o['status']),
              ),
            )),
      ],
    );
  }

  // 🔥 ORDERS (TRACKING VIEW)
  Widget _orders() {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final o = orders[i];

        return Card(
          elevation: 5,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order #${i + 1}"),
                    statusBadge(o['status']),
                  ],
                ),

                const SizedBox(height: 6),

                Text("Pickup: ${o['pickup']}"),
                Text("Total: R${o['total']}"),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 6,
                  children: [
                    ElevatedButton(
                      onPressed: () => updateStatus(i, "Pending"),
                      child: const Text("Pending"),
                    ),
                    ElevatedButton(
                      onPressed: () => updateStatus(i, "Shipped"),
                      child: const Text("Shipped"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}