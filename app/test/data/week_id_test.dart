import 'package:flutter_test/flutter_test.dart';
import 'package:znacht/data/models/models.dart';

void main() {
  test('Format 2026-W48', () {
    expect(WeekId.fromDate(DateTime(2026, 11, 24)).toString(), '2026-W48');
    expect(WeekId.fromDate(DateTime(2026, 11, 23)).toString(), '2026-W48');
    expect(WeekId.fromDate(DateTime(2026, 11, 29)).toString(), '2026-W48');
    expect(WeekId.fromDate(DateTime(2026, 11, 30)).toString(), '2026-W49');
  });

  test('Jahreswechsel nach ISO 8601', () {
    expect(WeekId.fromDate(DateTime(2026, 1, 1)).toString(), '2026-W01');
    expect(WeekId.fromDate(DateTime(2027, 1, 1)).toString(), '2026-W53');
    expect(WeekId.fromDate(DateTime(2024, 12, 30)).toString(), '2025-W01');
  });

  test('Montag, nächste und vorherige Woche', () {
    final w = WeekId.parse('2026-W48');
    expect(w.monday, DateTime.utc(2026, 11, 23));
    expect(w.next.toString(), '2026-W49');
    expect(w.previous.toString(), '2026-W47');
    expect(WeekId.parse('2026-W53').next.toString(), '2027-W01');
  });

  test('ungültige IDs', () {
    expect(() => WeekId.parse('2026-48'), throwsFormatException);
    expect(() => WeekId.parse('2025-W53'), throwsFormatException);
    expect(() => WeekId.parse('2026-W00'), throwsFormatException);
  });
}
