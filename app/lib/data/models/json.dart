import 'package:cloud_firestore/cloud_firestore.dart';

/// Hilfsfunktionen zum Lesen von Firestore-Dokumenten.
///
/// Firestore liefert Zahlen je nach Wert als `int` oder `double`, Listen als
/// `List<dynamic>` und Zeitstempel als [Timestamp]. Diese Funktionen
/// vereinheitlichen das.
typedef Json = Map<String, dynamic>;

double toDouble(Object? v, [double fallback = 0]) => v is num ? v.toDouble() : fallback;

double? toDoubleOrNull(Object? v) => v is num ? v.toDouble() : null;

int toInt(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;

List<String> toStringList(Object? v) =>
    v is List ? v.whereType<String>().toList(growable: false) : const [];

List<int> toIntList(Object? v) =>
    v is List ? v.whereType<num>().map((n) => n.toInt()).toList(growable: false) : const [];

DateTime? toDateTime(Object? v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}
