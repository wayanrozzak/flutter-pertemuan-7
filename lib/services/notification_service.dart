
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Meminta izin notifikasi
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Notification permission: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.denied) {
      debugPrint('Izin notifikasi ditolak pengguna.');
      return;
    }

    // 2. Mendengarkan Firebase Installation ID (FID)
    _messaging.onRegistered.listen(
      (String installationId) {
        debugPrint('FIREBASE INSTALLATION ID: $installationId');
      },
      onError: (error) {
        debugPrint('Gagal mendapatkan FID: $error');
      },
    );

    // 3. Mendaftarkan perangkat ke Firebase Cloud Messaging
    await _messaging.register();

    // 4. Menerima notifikasi ketika aplikasi terbuka
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notifikasi diterima saat aplikasi terbuka');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
    });

    // 5. Menangani ketika pengguna membuka notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint('Notifikasi dibuka oleh pengguna');
        debugPrint('Data: ${message.data}');
      },
    );
  }
}
