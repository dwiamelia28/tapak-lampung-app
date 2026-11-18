import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.hour = 19,
    this.minute = 0,
    this.days = const {1, 2, 3, 4, 5, 6, 7},
  });
  final bool enabled;
  final int hour;
  final int minute;
  final Set<int> days; // 1 = Senin ... 7 = Minggu

  static const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';

  String get daysLabel {
    if (days.length == 7) return 'Setiap hari';
    final s = days.toList()..sort();
    return s.map((d) => dayNames[d - 1]).join(', ');
  }

  ReminderSettings copyWith({bool? enabled, int? hour, int? minute, Set<int>? days}) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        days: days ?? this.days,
      );

  factory ReminderSettings.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return const ReminderSettings();
    final days = (d['days'] as List?)?.map((e) => (e as num).toInt()).toSet() ?? {1, 2, 3, 4, 5, 6, 7};
    return ReminderSettings(
      enabled: (d['enabled'] as bool?) ?? false,
      hour: (d['hour'] as num?)?.toInt() ?? 19,
      minute: (d['minute'] as num?)?.toInt() ?? 0,
      days: days,
    );
  }
}
