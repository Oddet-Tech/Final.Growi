import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:growi_project/appscreen/payment.dart';
import 'package:image_picker/image_picker.dart';
import 'appscreen/models.dart';

// ─── GLOBAL DATA ────────────────────────────────────────────────────────────
List<Models> globalPhonesList = [];
List<Map<String, dynamic>> orders = [];

// ─── ADMIN ──────────────────────────────────────────────────────────────────
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

  List<XFile> selectedImages = [];
  List<Uint8List> webImages = [];
  Set<String> selectedColors = {};

  Map<int, Uint8List?> shippingReceipts = {};
  Map<int, XFile?> shippingReceiptFiles = {};

  final List<String> phoneColors = [
    "Black",
    "White",
    "Silver",
    "Gold",
    "Blue",
    "Red",
    "Green",
    "Purple",
    "Pink",
    "Gray",
    "Titanium",
    "Rose Gold",
    "Midnight",
    "Starlight",
    "Sierra Blue",
    "Graphite",
    "Orange",
    "Cream",
    "Navy",
    "Lavender",
  ];

  double get pendingSales =>
      orders.fold(0, (sum, o) => sum + (o['total'] ?? 0));

  double get estimatedSales =>
      globalPhonesList.fold(0, (sum, p) => sum + (p.discountPrice ?? p.price));

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      selectedImages = picked;
      webImages.clear();
      for (var img in picked) {
        webImages.add(await img.readAsBytes());
      }
      setState(() {});
    }
  }

  Future<void> pickShippingReceipt(int orderIndex) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        shippingReceipts[orderIndex] = bytes;
        shippingReceiptFiles[orderIndex] = picked;
        if (orderIndex < orders.length) {
          orders[orderIndex]['receipt'] = bytes;
        }
      });
    }
  }

  // ── Product CRUD ──────────────────────────────────────────────────────────

  void addPhone() {
    final parsedPrice = double.tryParse(price.text);
    if (name.text.isEmpty ||
        desc.text.isEmpty ||
        parsedPrice == null ||
        webImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and pick at least one image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newPhone = Models(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.text.trim(),
      description: desc.text.trim(),
      price: parsedPrice,
      discountPrice: null,
      imagePath: selectedImages,
      webImages: List<Uint8List>.from(webImages),
      colors: selectedColors.isNotEmpty ? selectedColors.toList() : ['Default'],
      stockQuantity: 10,
      inStock: true,
      category: 'General',
      requiresShipping: true,
      shippingFee: 0,
      isFeatured: false,
      isApproved: true,
      sellerId: 'admin',
      sellerName: 'Admin',
      views: 0,
      purchases: 0,
      createdAt: DateTime.now(),
    );

    setState(() {
      globalPhonesList.add(newPhone);
      name.clear();
      desc.clear();
      price.clear();
      selectedImages.clear();
      webImages.clear();
      selectedColors.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Product added successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void editPhone(int index) {
    final phone = globalPhonesList[index];
    final nameCtrl = TextEditingController(text: phone.name);
    final descCtrl = TextEditingController(text: phone.description);
    final priceCtrl = TextEditingController(text: phone.price.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F7A4C),
            ),
            onPressed: () {
              final parsedPrice = double.tryParse(priceCtrl.text);
              if (parsedPrice != null) {
                // Changes written to globalPhonesList → UserPurchase rebuilds
                // automatically because it reads globalPhonesList directly.
                setState(() {
                  globalPhonesList[index] = phone.copyWith(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    price: parsedPrice,
                  );
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void deletePhone(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text(
          'Remove "${globalPhonesList[index].name}" from the store?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => globalPhonesList.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void toggleSale(int index) {
    final phone = globalPhonesList[index];
    setState(() {
      globalPhonesList[index] = phone.copyWith(
        discountPrice: phone.discountPrice == null ? (phone.price * 0.9) : null,
      );
    });
  }

  void updateStatus(int i, String status) =>
      setState(() => orders[i]['status'] = status);

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget statusBadge(String status) {
    final color = status == "Shipped" ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: child,
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );

  Widget _tab(String label, int i) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _selectedTab = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _selectedTab == i
              ? const Color(0xFF1F7A4C)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _selectedTab == i ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EED2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Growi Admin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _tab("Listing", 0),
                  _tab("Pending", 1),
                  _tab("Orders", 2),
                ],
              ),
            ),
          ),

          // Sales card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F7A4C), Color(0xFF34C759)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Estimated Sales",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "R${estimatedSales.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

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

  // ── Listing tab ───────────────────────────────────────────────────────────

  Widget _listing() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Add product form ──
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Product Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: name,
                decoration: _inputDecoration("Product Name"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: desc,
                maxLines: 4,
                decoration: _inputDecoration("Description"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Price"),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Image picker ──
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Product Images",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F7A4C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Images"),
                ),
              ),
              if (webImages.isNotEmpty) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: webImages.length,
                    itemBuilder: (_, i) => Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          webImages[i],
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
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
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Colors ──
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Available Colors",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: phoneColors.map((c) {
                  final selected = selectedColors.contains(c);
                  return FilterChip(
                    selectedColor: Colors.green.shade200,
                    label: Text(c),
                    selected: selected,
                    onSelected: (v) => setState(
                      () =>
                          v ? selectedColors.add(c) : selectedColors.remove(c),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F7A4C),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: addPhone,
          child: const Text("Add Product", style: TextStyle(fontSize: 18)),
        ),

        const SizedBox(height: 24),

        // ── Current products ──
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (globalPhonesList.isEmpty)
                const Text("No products added yet.")
              else
                ...globalPhonesList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final phone = entry.value;
                  final onSale = phone.discountPrice != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Product image(s) with sale banner overlay ──
                        if (phone.webImages != null &&
                            phone.webImages!.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 180,
                                  width: double.infinity,
                                  child: PageView.builder(
                                    itemCount: phone.webImages!.length,
                                    itemBuilder: (_, imgIdx) => Image.memory(
                                      phone.webImages![imgIdx],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
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
                                  ),
                                ),

                                // Sale banner — top-left ribbon
                                if (onSale)
                                  Positioned(
                                    top: 12,
                                    left: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.local_offer,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "10% OFF  •  R${phone.discountPrice!.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Image count pill — bottom-right
                                if (phone.webImages!.length > 1)
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${phone.webImages!.length} photos",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        // ── Text info + action buttons ──
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                phone.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                phone.description,
                                style: TextStyle(color: Colors.grey.shade600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (onSale) ...[
                                    Text(
                                      "R${phone.price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    "R${(phone.discountPrice ?? phone.price).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: onSale
                                          ? Colors.red
                                          : const Color(0xFF1F7A4C),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    onPressed: () => editPhone(index),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit'),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: onSale
                                          ? Colors.grey
                                          : Colors.orange,
                                    ),
                                    onPressed: () => toggleSale(index),
                                    icon: const Icon(
                                      Icons.local_offer,
                                      size: 16,
                                    ),
                                    label: Text(
                                      onSale ? 'Remove Sale' : 'Mark Sale',
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () => deletePhone(index),
                                    icon: const Icon(Icons.delete, size: 16),
                                    label: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Pending tab ───────────────────────────────────────────────────────────

  Widget _pendingView() {
    final pendingOrders = orders
        .where((o) => o['status'] == "Pending")
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Pending Amount: R${pendingSales.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        if (pendingOrders.isEmpty)
          const Center(child: Text("No pending orders.")),
        ...pendingOrders.map(
          (o) => Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                "Order ${orders.indexOf(o) + 1}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(o['pickup'] ?? ""),
              trailing: statusBadge(o['status']),
            ),
          ),
        ),
      ],
    );
  }

  // ── Orders tab ────────────────────────────────────────────────────────────

  Widget _orders() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final o = orders[i];
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order #${i + 1}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    statusBadge(o['status']),
                  ],
                ),
                const SizedBox(height: 10),
                Text("Pickup: ${o['pickup']}"),
                Text("Total: R${o['total']}"),
                const SizedBox(height: 20),
                const Text(
                  "Shipping Receipt",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => pickShippingReceipt(i),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text("Upload Receipt"),
                ),
                const SizedBox(height: 10),
                if (o['receipt'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      o['receipt'] as Uint8List,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
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
                  ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () => updateStatus(i, "Pending"),
                      child: const Text("Pending"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: shippingReceipts[i] == null
                          ? null
                          : () => updateStatus(i, "Shipped"),
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

// ─── USER PURCHASE ───────────────────────────────────────────────────────────
class UserPurchase extends StatefulWidget {
  const UserPurchase({super.key});

  @override
  State<UserPurchase> createState() => _UserPurchaseState();
}

class _UserPurchaseState extends State<UserPurchase> {
  final List<Map<String, dynamic>> cart = [];
  final Map<int, String> selectedColors = {};

  bool showCart = false;
  double totalPrice = 0;

  final List<String> pepStores = [
    "PEP - East London CBD",
    "PEP - Hemingways Mall",
    "PEP - Mdantsane City",
    "PEP - Beacon Bay",
  ];

  int get cartCount => cart.length;

  void addToCart(Models phone, int index) {
    final color = selectedColors[index];
    if (color == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a color")));
      return;
    }

    setState(() {
      cart.add({"item": phone, "color": color});
      // Use discountPrice if on sale, otherwise regular price
      totalPrice += phone.discountPrice ?? phone.price;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${phone.name} added ($color)"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void removeFromCart(int i) {
    setState(() {
      final phone = cart[i]["item"] as Models;
      totalPrice -= phone.discountPrice ?? phone.price;
      cart.removeAt(i);
    });
  }

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
          cartItems: cart.map((e) => e["item"] as Models).toList(),
          totalPrice: totalPrice,
          pickupLocation: "",
          themeColor: const Color(0xFF1F7A4C),
        ),
      ),
    );
  }

  // ── Shop ──────────────────────────────────────────────────────────────────

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
        final phone = globalPhonesList[i];
        final onSale = phone.discountPrice != null;

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
              // ── Product image with sale banner ──
              if (phone.webImages != null && phone.webImages!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: PageView.builder(
                          itemCount: phone.webImages!.length,
                          itemBuilder: (_, imgIdx) => Image.memory(
                            phone.webImages![imgIdx],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
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
                        ),
                      ),

                      // Sale banner ribbon — visible to user when on sale
                      if (onSale)
                        Positioned(
                          top: 14,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "ON SALE  •  10% OFF",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      phone.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Colors
                    if (phone.colors.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: phone.colors.map((color) {
                          final selected = selectedColors[i] == color;
                          return ChoiceChip(
                            selectedColor: Colors.green.shade200,
                            label: Text(color),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => selectedColors[i] = color),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (onSale)
                              Text(
                                "R${phone.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            Text(
                              "R${(phone.discountPrice ?? phone.price).toStringAsFixed(2)}",
                              style: TextStyle(
                                color: onSale
                                    ? Colors.red
                                    : const Color(0xFF1F7A4C),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
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
                          onPressed: () => addToCart(phone, i),
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text("Add"),
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

  // ── Cart ──────────────────────────────────────────────────────────────────

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
              final phone = cart[i]["item"] as Models;
              final color = cart[i]["color"];
              final onSale = phone.discountPrice != null;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  minLeadingWidth: 56,
                  contentPadding: const EdgeInsets.all(14),
                  leading:
                      phone.webImages != null && phone.webImages!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            phone.webImages!.first,
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 46,
                                height: 46,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.shopping_bag),
                  title: Text(
                    phone.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Color: $color"),
                      Text(
                        "R${(phone.discountPrice ?? phone.price).toStringAsFixed(2)}",
                        style: TextStyle(
                          color: onSale ? Colors.red : const Color(0xFF1F7A4C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    "R${totalPrice.toStringAsFixed(2)}",
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

  // ── Build ─────────────────────────────────────────────────────────────────

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
                  onPressed: () => setState(() => showCart = !showCart),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
