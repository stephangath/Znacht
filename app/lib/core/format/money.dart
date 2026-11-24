/// Beträge im Schweizer Format: `CHF 12.50`, ab 1000 mit Apostroph (`CHF 1’250.00`).
String formatChf(num amount) {
  final negative = amount < 0;
  final cents = (amount.abs() * 100).round();
  final francs = (cents ~/ 100).toString();
  final rappen = (cents % 100).toString().padLeft(2, '0');
  final grouped = StringBuffer();
  for (var i = 0; i < francs.length; i++) {
    if (i > 0 && (francs.length - i) % 3 == 0) grouped.write('’');
    grouped.write(francs[i]);
  }
  return '${negative ? '−' : ''}CHF $grouped.$rappen';
}

/// Preisänderung mit Vorzeichen, z. B. `+ CHF 2.40` oder `− CHF 1.10`.
String formatChfDelta(num delta) {
  if (delta.abs() < 0.005) return formatChf(0);
  return '${delta > 0 ? '+' : '−'} ${formatChf(delta.abs())}';
}
