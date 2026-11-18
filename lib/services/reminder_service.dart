import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_model.dart';
import '../models/visit_model.dart';
import 'fcm_service.dart';

/// Notifikasi LOKAL terjadwal di perangkat (zona waktu Asia/Jakarta).
/// Ini BERBEDA dari push notification FCM: tidak ada server yang mengirim pesan;
/// jadwalnya disimpan di HP dan dihitung dari data pengguna.
/// Memakai mode "inexact" agar tidak butuh izin alarm tepat; waktu tampil bisa
/// bergeser beberapa menit saat HP dalam mode hemat daya.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'tapak_reminder',
    'Pengingat Tapak Lampung',
    description: 'Pengingat kunjungan dan belajar budaya.',
    importance: Importance.high,
  );

  late tz.Location _jkt;
  bool _ready = false;

  FlutterLocalNotificationsPlugin get _local => FcmService.instance.local;

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      _jkt = tz.getLocation('Asia/Jakarta');
      tz.setLocalLocation(_jkt);
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      _ready = true;
    } catch (e) {
      debugPrint('ReminderService init gagal: $e');
    }
  }

  NotificationDetails get _details => NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );

  int _hash(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h;
  }

  int _visitId(String id, int slot) => 1000 + (_hash(id) % 100000000) * 10 + slot;

  Future<void> _schedule(
    int id,
    String title,
    String body,
    tz.TZDateTime when,
    Map<String, dynamic> payload, {
    DateTimeComponents? match,
  }) =>
      _local.zonedSchedule(
        id,
        title,
        body,
        when,
        _details,
        payload: jsonEncode(payload),
        matchDateTimeComponents: match,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

  /// Menyelaraskan jadwal dengan daftar rencana saat ini: membatalkan semua
  /// pengingat kunjungan lama lalu menjadwalkan ulang yang masih relevan.
  /// Dipanggil setiap kali data rencana berubah (tambah, edit tanggal, hapus, selesai).
  Future<void> syncVisits(List<VisitModel> plans) async {
    if (!_ready) return;
    try {
      final pending = await _local.pendingNotificationRequests();
      for (final p in pending) {
        if ((p.payload ?? '').contains('"kind":"visit"')) await _local.cancel(p.id);
      }
      final now = tz.TZDateTime.now(_jkt);
      for (final v in plans) {
        if (v.visited || !v.reminderOn) continue;
        final dayOf = tz.TZDateTime(_jkt, v.date.year, v.date.month, v.date.day, 7, 0);
        final dayBefore = dayOf.subtract(const Duration(hours: 13)); // 18.00 hari sebelumnya
        final payload = {'route': '/visits/${v.id}', 'kind': 'visit'};
        if (dayBefore.isAfter(now)) {
          await _schedule(
            _visitId(v.id, 0),
            'Rencana kunjungan: ${v.title}',
            'Besok waktunya menjelajahi budaya Lampung! Jangan lupa rencana kunjunganmu.',
            dayBefore,
            payload,
          );
        }
        if (dayOf.isAfter(now)) {
          await _schedule(
            _visitId(v.id, 1),
            'Rencana kunjungan: ${v.title}',
            'Hari ini waktunya mengunjungi tempat yang sudah kamu rencanakan. Selamat menjelajah!',
            dayOf,
            payload,
          );
        }
      }
    } catch (e) {
      debugPrint('syncVisits gagal: $e');
    }
  }

  /// Pengingat belajar mingguan: satu jadwal berulang untuk tiap hari terpilih.
  Future<void> syncStudy(ReminderSettings s) async {
    if (!_ready) return;
    try {
      for (var d = 1; d <= 7; d++) {
        await _local.cancel(d);
      }
      if (!s.enabled) return;
      final now = tz.TZDateTime.now(_jkt);
      for (final day in s.days) {
        var when = tz.TZDateTime(_jkt, now.year, now.month, now.day, s.hour, s.minute);
        while (when.weekday != day || !when.isAfter(now)) {
          when = when.add(const Duration(days: 1));
        }
        await _schedule(
          day,
          'Waktunya belajar budaya',
          'Yuk, luangkan waktu sebentar untuk mengenal budaya Lampung hari ini!',
          when,
          {'route': '/study', 'kind': 'study'},
          match: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (e) {
      debugPrint('syncStudy gagal: $e');
    }
  }

  /// Menampilkan satu notifikasi lokal sekarang (untuk menguji tampilan pengingat).
  Future<void> showTest() => _local.show(
        999999,
        'Uji pengingat',
        'Ini notifikasi LOKAL dari perangkat, bukan push FCM dari server.',
        _details,
        payload: jsonEncode({'route': '/reminder', 'kind': 'test'}),
      );

  Future<void> cancelAll() async {
    try {
      await _local.cancelAll();
    } catch (_) {}
  }
}
