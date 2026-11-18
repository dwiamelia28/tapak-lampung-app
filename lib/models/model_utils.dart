import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? tsToDate(dynamic v) => v is Timestamp ? v.toDate() : null;

List<String> strList(dynamic v) =>
    (v as List?)?.map((e) => e.toString()).toList() ?? <String>[];

List<Map<String, dynamic>> mapList(dynamic v) => (v as List?)
        ?.whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList() ??
    <Map<String, dynamic>>[];
