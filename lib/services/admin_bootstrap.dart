import 'package:flutter/foundation.dart';

class AdminBootstrap {
  static Future<void> ensureAdminAccountExists() async {
    debugPrint(
      'Admin account creation is intentionally disabled in the client app. '
      'Create the admin account securely from Firebase Console or a trusted backend.',
    );
  }
}
