import 'package:firebase_core/firebase_core.dart';

/// Optionen für das Emulator-Projekt `demo-znacht`.
///
/// Projekte mit dem Präfix `demo-` existieren nur in den lokalen Emulatoren;
/// die Werte hier sind Platzhalter und keine Schlüssel. Die Konfiguration für
/// ein echtes Firebase-Projekt folgt erst mit der Auslieferung (M7).
const demoFirebaseOptions = FirebaseOptions(
  apiKey: 'demo-api-key',
  appId: '1:000000000000:web:0000000000000000000000',
  messagingSenderId: '000000000000',
  projectId: 'demo-znacht',
  authDomain: 'demo-znacht.firebaseapp.com',
);
