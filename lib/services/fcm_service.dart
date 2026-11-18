import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/routes/app_router.dart';
import '../firebase_options.dart';

/// Handler pesan saat aplikasi di background/terminated. Harus fungsi top-level.
/// Pesan berjenis "notification" ditampilkan otomatis oleh sistem Android.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background: ${message.messageId}');
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'tapak_high',
    'Notifikasi Tapak Lampung',
    description: 'Pemberitahuan perjalanan budaya dan pengumuman.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlugin get local => _local;
  final ValueNotifier<String?> token = ValueNotifier<String?>(null);
  final ValueNotifier<AuthorizationStatus?> permission = ValueNotifier<AuthorizationStatus?>(null);
  bool _inited = false;
  String? _pendingRoute;

  /// Dipanggil sekali saat aplikasi mulai (sebelum login).
  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    await _local.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onDidReceiveNotificationResponse: (r) => _openPayload(r.payload),
    );
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      _record(m);
      _navigate(m.data);
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      token.value = t;
      saveToken(t);
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _record(initial);
      _pendingRoute = _routeFrom(initial.data); // dibuka setelah masuk beranda
    }
  }

  /// Meminta izin notifikasi (Android 13+) lalu mengambil dan menyimpan token.
  Future<void> requestPermissionAndToken() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      permission.value = settings.authorizationStatus;
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      final t = await FirebaseMessaging.instance.getToken();
      token.value = t;
      if (t != null) await saveToken(t);
    } catch (e) {
      debugPrint('FCM izin/token gagal: $e');
    }
  }

  Future<void> saveToken(String t) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(t)
          .set({
        'token': t,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Simpan token gagal: $e');
    }
  }

  /// Dipanggil sebelum logout agar perangkat ini tidak menerima notifikasi akun lama.
  Future<void> removeToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final t = token.value ?? await FirebaseMessaging.instance.getToken();
    if (user == null || t == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(t)
          .delete();
    } catch (_) {}
  }

  /// Membuka halaman tujuan dari notifikasi yang mengaktifkan aplikasi saat terminated.
  void flushPending() {
    final r = _pendingRoute;
    _pendingRoute = null;
    if (r != null) appRouter.push(r);
  }

  Future<void> _onForeground(RemoteMessage m) async {
    final title = m.notification?.title ?? m.data['title']?.toString() ?? 'TAPAK LAMPUNG';
    final body = m.notification?.body ?? m.data['body']?.toString() ?? '';
    await _local.show(
      (m.messageId ?? DateTime.now().toIso8601String()).hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(m.data),
    );
    await _record(m);
  }

  /// Menyimpan notifikasi masuk ke daftar notifikasi dalam aplikasi (Firestore).
  Future<void> _record(RemoteMessage m) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final title = m.notification?.title ?? m.data['title']?.toString() ?? '';
    final body = m.notification?.body ?? m.data['body']?.toString() ?? '';
    if (title.isEmpty && body.isEmpty) return;
    final id = (m.messageId ?? DateTime.now().millisecondsSinceEpoch.toString())
        .replaceAll('/', '_');
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(id).set({
        'userId': user.uid,
        'title': title,
        'body': body,
        'type': 'fcm',
        'targetId': m.data['targetId']?.toString() ?? '',
        'route': m.data['route']?.toString() ?? '',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Sudah tercatat sebelumnya (id sama) atau gagal; abaikan.
    }
  }

  void _openPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      _navigate(data);
    } catch (_) {}
  }

  String _routeFrom(Map<String, dynamic> data) {
    final route = data['route']?.toString() ?? '';
    if (route.startsWith('/')) return route;
    final type = data['type']?.toString() ?? '';
    final id = data['targetId']?.toString() ?? '';
    if (type == 'chapter' && id.isNotEmpty) return '/chapter/$id';
    return '/notifications';
  }

  void _navigate(Map<String, dynamic> data) => appRouter.push(_routeFrom(data));
}
