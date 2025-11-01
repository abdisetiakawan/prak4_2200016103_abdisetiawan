import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Gantilah seluruh nilai placeholder di file ini dengan konfigurasi Firebase kamu
/// menggunakan perintah `flutterfire configure`. File ini hanya menjadi pengingat
/// agar proyek dapat dikompilasi sebelum konfigurasi asli digenerate.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'GANTI_DENGAN_API_KEY_WEB',
        appId: 'GANTI_DENGAN_APP_ID_WEB',
        messagingSenderId: 'GANTI_DENGAN_SENDER_ID',
        projectId: 'GANTI_DENGAN_PROJECT_ID',
        authDomain: 'GANTI_DENGAN_AUTH_DOMAIN',
        storageBucket: 'GANTI_DENGAN_STORAGE_BUCKET',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'GANTI_DENGAN_API_KEY_ANDROID',
          appId: 'GANTI_DENGAN_APP_ID_ANDROID',
          messagingSenderId: 'GANTI_DENGAN_SENDER_ID',
          projectId: 'GANTI_DENGAN_PROJECT_ID',
          storageBucket: 'GANTI_DENGAN_STORAGE_BUCKET',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'GANTI_DENGAN_API_KEY_IOS',
          appId: 'GANTI_DENGAN_APP_ID_IOS',
          messagingSenderId: 'GANTI_DENGAN_SENDER_ID',
          projectId: 'GANTI_DENGAN_PROJECT_ID',
          storageBucket: 'GANTI_DENGAN_STORAGE_BUCKET',
          iosBundleId: 'GANTI_DENGAN_IOS_BUNDLE_ID',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return const FirebaseOptions(
          apiKey: 'GANTI_DENGAN_API_KEY_DESKTOP',
          appId: 'GANTI_DENGAN_APP_ID_DESKTOP',
          messagingSenderId: 'GANTI_DENGAN_SENDER_ID',
          projectId: 'GANTI_DENGAN_PROJECT_ID',
          storageBucket: 'GANTI_DENGAN_STORAGE_BUCKET',
        );
      default:
        throw UnsupportedError(
          'Konfigurasi Firebase belum diatur untuk platform ${defaultTargetPlatform.name}',
        );
    }
  }
}
