import 'enums.dart';
import 'json.dart';

/// `feedback/{autoId}` – für Nutzer nur schreibbar.
class FeedbackEntry {
  const FeedbackEntry({
    required this.householdId,
    required this.uid,
    required this.screen,
    required this.type,
    this.text,
    this.answers,
  });

  final String householdId;
  final String uid;
  final String screen;
  final FeedbackType type;
  final String? text;
  final Json? answers;

  /// Ohne `createdAt`: das setzt das Repository als Server-Zeitstempel.
  Json toJson() => {
        'householdId': householdId,
        'uid': uid,
        'screen': screen,
        'type': type.wire,
        'text': text,
        'answers': answers,
      };
}

/// `events/{autoId}` – für Nutzer nur schreibbar.
class AppEvent {
  const AppEvent({
    required this.householdId,
    required this.uid,
    required this.name,
    this.props,
  });

  final String householdId;
  final String uid;
  final String name;
  final Json? props;

  /// Ohne `createdAt`: das setzt das Repository als Server-Zeitstempel.
  Json toJson() => {
        'householdId': householdId,
        'uid': uid,
        'name': name,
        'props': props,
      };
}
