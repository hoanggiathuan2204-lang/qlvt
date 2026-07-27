import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDWCpPGAG65ffLcKyzO3_BJTqvI6dVhNK0',
        authDomain: 'qlvt-4d1fc.firebaseapp.com',
        appId: '1:111742463162:web:59f3678af1e7199e24e683',
        messagingSenderId: '111742463162',
        projectId: 'qlvt-4d1fc',
        storageBucket: 'qlvt-4d1fc.firebasestorage.app',
        measurementId: 'G-SWFN3TX1M9',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyCXc2NqXW9DuJVzM7S18XUbpgNoOt38ZLA',
          appId: '1:111742463162:android:41c6f6a7e18f6dc224e683',
          messagingSenderId: '111742463162',
          projectId: 'qlvt-4d1fc',
          storageBucket: 'qlvt-4d1fc.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDqzmtuqbkI_yMwhmpEbTFLX-NiFgssmUk',
          appId: '1:111742463162:ios:0e531d5a61dafd1424e683',
          messagingSenderId: '111742463162',
          projectId: 'qlvt-4d1fc',
          storageBucket: 'qlvt-4d1fc.firebasestorage.app',
          iosBundleId: 'com.anhduong.qlvt',
        );
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyCXc2NqXW9DuJVzM7S18XUbpgNoOt38ZLA',
          appId: '1:111742463162:ios:41c6f6a7e18f6dc224e683',
          messagingSenderId: '111742463162',
          projectId: 'qlvt-4d1fc',
          storageBucket: 'qlvt-4d1fc.firebasestorage.app',
          iosBundleId: 'com.anhduong.qlvt',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return const FirebaseOptions(
          apiKey: 'AIzaSyCXc2NqXW9DuJVzM7S18XUbpgNoOt38ZLA',
          appId: '1:111742463162:android:41c6f6a7e18f6dc224e683',
          messagingSenderId: '111742463162',
          projectId: 'qlvt-4d1fc',
          storageBucket: 'qlvt-4d1fc.firebasestorage.app',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform. '
          'Please add the necessary config files to the app.',
        );
    }
  }
}
