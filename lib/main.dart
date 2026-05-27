import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:growi_project/appscreen/homescreen.dart';
import 'package:growi_project/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growi.App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(), //point all work from the main to the homescreen
    );
  }
}
