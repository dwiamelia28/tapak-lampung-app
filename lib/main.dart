import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart'; // dihasilkan oleh: flutterfire configure
import 'services/audio_service.dart';
import 'services/fcm_service.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await AudioService.instance.init();
  await FcmService.instance.init();
  await ReminderService.instance.init();
  runApp(const ProviderScope(child: TapakLampungApp()));
}
