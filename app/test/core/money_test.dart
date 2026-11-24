import 'package:flutter_test/flutter_test.dart';
import 'package:znacht/core/format/money.dart';

void main() {
  test('Beträge als CHF 12.50', () {
    expect(formatChf(12.5), 'CHF 12.50');
    expect(formatChf(0), 'CHF 0.00');
    expect(formatChf(84.3), 'CHF 84.30');
    expect(formatChf(2.2), 'CHF 2.20');
    expect(formatChf(0.105), 'CHF 0.11');
  });

  test('Tausender mit Apostroph', () {
    expect(formatChf(1250), 'CHF 1’250.00');
    expect(formatChf(1234567.891), 'CHF 1’234’567.89');
  });

  test('Änderungen mit Vorzeichen', () {
    expect(formatChfDelta(2.4), '+ CHF 2.40');
    expect(formatChfDelta(-1.1), '− CHF 1.10');
    expect(formatChfDelta(0.001), 'CHF 0.00');
  });
}
