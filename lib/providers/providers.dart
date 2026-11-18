import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(FirebaseAuth.instance, FirebaseFirestore.instance),
);

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(FirebaseFirestore.instance),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authChanges,
);

final currentUserDocProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchUser(user.uid);
});

final progressProvider = StreamProvider<ProgressModel>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchProgress(user.uid);
});
