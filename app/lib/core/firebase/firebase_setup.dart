import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options_demo.dart';

/// Host der lokalen Emulatoren. Für ein Android-Gerät im Emulator später
/// z. B. `--dart-define=EMULATOR_HOST=10.0.2.2`.
const emulatorHost = String.fromEnvironment('EMULATOR_HOST', defaultValue: 'localhost');

/// Startet Firebase gegen die lokalen Emulatoren und meldet anonym an.
///
/// Bis zur Auslieferung (M7) gibt es keine Verbindung zu einem echten Projekt.
Future<User> initFirebase() async {
  await Firebase.initializeApp(options: demoFirebaseOptions);

  final auth = FirebaseAuth.instance;
  await auth.useAuthEmulator(emulatorHost, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);

  final current = auth.currentUser;
  if (current != null) return current;
  final cred = await auth.signInAnonymously();
  return cred.user!;
}
