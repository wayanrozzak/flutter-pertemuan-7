import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[BACKGROUND] ${message.notification?.title}');
  debugPrint('[BACKGROUND] ${message.notification?.body}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _listenersRegistered = false;

  /// Meminta izin notifikasi dan mengembalikan statusnya.
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final status = settings.authorizationStatus;

    debugPrint('Notification permission: ${status.name}');

    // Registrasi perangkat hanya jika izin diberikan.
    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      if (!_listenersRegistered) {
        // Mendengarkan Firebase Installation ID.
        _messaging.onRegistered.listen(
          (String installationId) {
            debugPrint('FIREBASE INSTALLATION ID: $installationId');
          },
          onError: (error) {
            debugPrint('Gagal mendapatkan FID: $error');
          },
        );

        // Menerima notifikasi ketika aplikasi terbuka.
        FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
            debugPrint('Notifikasi diterima saat aplikasi terbuka');
            debugPrint('Title: ${message.notification?.title}');
            debugPrint('Body: ${message.notification?.body}');
            debugPrint('Data: ${message.data}');
          },
        );

        // Menangani ketika pengguna membuka notifikasi.
        FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
            debugPrint('Notifikasi dibuka oleh pengguna');
            debugPrint('Data: ${message.data}');
          },
        );

        _listenersRegistered = true;
      }

      await _messaging.register();
      final token = await getToken();
      debugPrint('FCM Token: $token');
    }

    return status;
  }

  /// Mendapatkan token FCM perangkat
  Future<String?> getToken() async {
    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    return token;
  }

  /// Mendengarkan perubahan token FCM
  void listenTokenRefresh(void Function(String token) onRefresh) {
    // ignore: deprecated_member_use
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token diperbarui: $newToken');
      onRefresh(newToken);
    });
  }
}
