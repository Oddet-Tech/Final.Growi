import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EventApplication {
  final String fullName;
  final String idNumber;
  final String phone;
  final String email;
  final String address;

  final String eventName;
  final String eventType;
  final String eventDescription;
  final String venue;
  final String estimatedAttendance;

  final String status;

  final List<String> eventImages;

  final String idImage;
  final String selfieImage;
  final String posterImage;

  EventApplication({
    required this.fullName,
    required this.idNumber,
    required this.phone,
    required this.email,
    required this.address,
    required this.eventName,
    required this.eventType,
    required this.eventDescription,
    required this.venue,
    required this.estimatedAttendance,
    required this.status,
    required this.eventImages,
    required this.idImage,
    required this.selfieImage,
    required this.posterImage,
  });
}

List<EventApplication> globalApplications = [];
List<EventApplication> approvedEvents = [];

class EventApplicationPage extends StatefulWidget {
  const EventApplicationPage({super.key});

  @override
  State<EventApplicationPage> createState() => _EventApplicationPageState();
}

class _EventApplicationPageState extends State<EventApplicationPage> {
  final picker = ImagePicker();

  final TextEditingController fullName = TextEditingController();
  final TextEditingController idNumber = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();

  final TextEditingController eventName = TextEditingController();
  final TextEditingController eventType = TextEditingController();
  final TextEditingController eventDescription = TextEditingController();
  final TextEditingController venue = TextEditingController();
  final TextEditingController attendance = TextEditingController();

  Uint8List? idImage;
  Uint8List? selfieImage;
  Uint8List? posterImage;

  List<Uint8List> galleryImages = [];

  Future<void> pickID() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      idImage = await picked.readAsBytes();
      setState(() {});
    }
  }

  Future<void> pickSelfie() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      selfieImage = await picked.readAsBytes();
      setState(() {});
    }
  }

  Future<void> pickPoster() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      posterImage = await picked.readAsBytes();
      setState(() {});
    }
  }

  Future<void> pickGallery() async {
    final picked = await picker.pickMultiImage();

    galleryImages.clear();

    for (var img in picked) {
      final bytes = await img.readAsBytes();
      galleryImages.add(bytes);
    }

    setState(() {});
  }

  void submitApplication() {
    if (fullName.text.isEmpty ||
        idNumber.text.isEmpty ||
        eventName.text.isEmpty ||
        idImage == null ||
        selfieImage == null ||
        posterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete all required fields")),
      );

      return;
    }

    globalApplications.add(
      EventApplication(
        fullName: fullName.text,
        idNumber: idNumber.text,
        phone: phone.text,
        email: email.text,
        address: address.text,
        eventName: eventName.text,
        eventType: eventType.text,
        eventDescription: eventDescription.text,
        venue: venue.text,
        estimatedAttendance: attendance.text,
        status: "Pending",
        eventImages: [],
        idImage: "uploaded",
        selfieImage: "uploaded",
        posterImage: "uploaded",
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Application Submitted"),
      ),
    );
  }

  Widget uploadCard(String title, VoidCallback onTap, Uint8List? image) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.upload),
            label: const Text("Upload"),
          ),

          if (image != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  image,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
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
        ],
      ),
    );
  }

  InputDecoration field(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EED2),

      appBar: AppBar(
        title: const Text("Host An Event"),
        backgroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Organizer Verification",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          TextField(controller: fullName, decoration: field("Full Name")),

          const SizedBox(height: 16),

          TextField(
            controller: idNumber,
            decoration: field("ID Number / Passport"),
          ),

          const SizedBox(height: 16),

          TextField(controller: phone, decoration: field("Phone Number")),

          const SizedBox(height: 16),

          TextField(controller: email, decoration: field("Email")),

          const SizedBox(height: 16),

          TextField(controller: address, decoration: field("Address")),

          const SizedBox(height: 30),

          const Text(
            "Event Details",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          TextField(controller: eventName, decoration: field("Event Name")),

          const SizedBox(height: 16),

          TextField(controller: eventType, decoration: field("Event Type")),

          const SizedBox(height: 16),

          TextField(
            controller: eventDescription,
            maxLines: 4,
            decoration: field("Event Description"),
          ),

          const SizedBox(height: 16),

          TextField(controller: venue, decoration: field("Venue")),

          const SizedBox(height: 16),

          TextField(
            controller: attendance,
            decoration: field("Estimated Attendance"),
          ),

          const SizedBox(height: 30),

          uploadCard("Government ID", pickID, idImage),

          uploadCard("Selfie Verification", pickSelfie, selfieImage),

          uploadCard("Event Poster", pickPoster, posterImage),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F7A4C),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onPressed: submitApplication,
            child: const Text(
              "Submit Application",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
