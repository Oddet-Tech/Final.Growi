import 'package:flutter/material.dart';
import 'appscreen/models.dart';
import 'dart:io';
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _expandListingManager = false;
  String? _selectedImagePath;

  // ✅ IMAGE PICKER (REAL DEVICE)
  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImagePath = picked.path;
      });
    }
  }

  void _addPhone() {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty) return;

    final newPhone = Models(
      name: _nameController.text,
      description: _descriptionController.text,
      price: int.parse(_priceController.text),
      imagePath: _selectedImagePath,
    );

    setState(() {
      globalPhonesList.add(newPhone);
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _selectedImagePath = null;
    });
  }

  void _deletePhone(int index) {
    setState(() => globalPhonesList.removeAt(index));
  }

  // ORDER STATUS UPDATE
  void _updateStatus(int index, String status) {
    setState(() {
      orders[index]['status'] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),

      body: ListView(
        children: [

          // ================= LISTING =================
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Listing Manager',
                      style: TextStyle(fontSize: 20)),
                  trailing: Icon(_expandListingManager
                      ? Icons.expand_less
                      : Icons.expand_more),
                  onTap: () {
                    setState(() {
                      _expandListingManager = !_expandListingManager;
                    });
                  },
                ),

                if (_expandListingManager) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [

                        // IMAGE
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _selectedImagePath != null
                              ? Image.file(File(_selectedImagePath!),
                                  fit: BoxFit.cover)
                              : const Center(child: Text('No Image')),
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Pick Image'),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: 'Phone Name'),
                        ),

                        TextField(
                          controller: _descriptionController,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                        ),

                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price (R)',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: _addPhone,
                          child: const Text('Add Phone'),
                        ),
                      ],
                    ),
                  ),

                  // PHONE LIST
                  ...globalPhonesList.asMap().entries.map((entry) {
                    int index = entry.key;
                    var phone = entry.value;

                    return Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 4,
                      child: Column(
                        children: [
                          if (phone.imagePath != null)
                            Image.file(File(phone.imagePath!),
                                height: 180, fit: BoxFit.cover),

                          ListTile(
                            title: Text(phone.name,
                                style: const TextStyle(fontSize: 18)),
                            subtitle: Text(phone.description),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => _deletePhone(index),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Price: R${phone.price}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                ],
              ],
            ),
          ),

          // ================= USER MANAGEMENT =================
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: Column(
              children: [
                const ListTile(
                  title: Text('User Management',
                      style: TextStyle(fontSize: 20)),
                ),

                ...orders.asMap().entries.map((entry) {
                  int index = entry.key;
                  var order = entry.value;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(order['name']),
                          subtitle: Text("Status: ${order['status']}"),
                        ),

                        Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(index, 'Pending'),
                                child: const Text('Pending')),
                            ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(index, 'Accepted'),
                                child: const Text('Accepted')),
                            ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(index, 'Shipped'),
                                child: const Text('Shipped')),
                            ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(index, 'Delivered'),
                                child: const Text('Delivered')),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // ================= ANALYTICS =================
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: Column(
              children: [
                const ListTile(
                  title:
                      Text('Analytics', style: TextStyle(fontSize: 20)),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        "Total Phones: ${globalPhonesList.length}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),

                      ...globalPhonesList.map((p) => ListTile(
                            title: Text(p.name),
                            trailing: Text("R${p.price}"),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}