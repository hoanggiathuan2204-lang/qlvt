import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool _configured = false;

  static bool get isConfigured => _configured;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      final hasPlaceholder =
          options.apiKey.contains('YOUR_') ||
          options.projectId.contains('YOUR_') ||
          options.appId.contains('YOUR_');

      if (hasPlaceholder) {
        _configured = false;
        _initialized = true;
        return;
      }

      await Firebase.initializeApp(options: options);
      _configured = true;
    } catch (_) {
      _configured = false;
    } finally {
      _initialized = true;
    }
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static Future<User?> signIn(String email, String password) async {
    if (!_configured) {
      throw Exception(
        'Firebase chưa được cấu hình. Hãy dùng tài khoản mẫu hoặc cấu hình Firebase thật.',
      );
    }
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  static Future<User?> signInAnonymously() async {
    if (!_configured) return null;
    final credential = await auth.signInAnonymously();
    return credential.user;
  }

  static Future<void> signOut() async {
    if (!_configured) return;
    await auth.signOut();
  }
}
