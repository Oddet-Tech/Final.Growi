import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:growi_project/appscreen/homescreen.dart';
import 'package:growi_project/firebase_options.dart';

Future<void> _handleFirebaseEmailAction() async {
  final uri = Uri.base;
  final mode = uri.queryParameters['mode'];
  final oobCode = uri.queryParameters['oobCode'];

  if (mode == null || oobCode == null) {
    return;
  }

  try {
    await FirebaseAuth.instance.applyActionCode(oobCode);
    await FirebaseAuth.instance.currentUser?.reload();
  } catch (e) {
    debugPrint('Firebase email action error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (!mounted) return;
    final loadingContext = context;
    await Future.wait([
      for (final assetPath in const [
        'assets/Icon.png',
        'assets/Clothing.png',
        'assets/ticket.png',
      ])
        precacheImage(AssetImage(assetPath), loadingContext),
    ]);
    unawaited(_handleFirebaseEmailAction());
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growi.App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _isInitialized ? const HomePage() : const LoadingPage(),
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EED2),
      body: Center(
        child: AnimatedBuilder(
          animation: _bounceController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Icon.png', width: 150, height: 150),
              SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Loading',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -12 * _bounceController.value),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
