import 'enums.dart';
import 'json.dart';

/// Wochen-ID im Format `2026-W48` (ISO-8601, Wochenbeginn Montag).
class WeekId implements Comparable<WeekId> {
  const WeekId(this.year, this.week);

  final int year;
  final int week;

  /// ISO-Woche des Datums (nur das Kalenderdatum zählt, nicht die Uhrzeit).
  factory WeekId.fromDate(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    // Donnerstag derselben Woche bestimmt das ISO-Jahr.
    final thursday = d.add(Duration(days: 4 - d.weekday));
    final firstDay = DateTime.utc(thursday.year, 1, 1);
    final week = thursday.difference(firstDay).inDays ~/ 7 + 1;
    return WeekId(thursday.year, week);
  }

  static final _pattern = RegExp(r'^(\d{4})-W(\d{2})$');

  static WeekId parse(String s) {
    final m = _pattern.firstMatch(s);
    if (m == null) throw FormatException('Ungültige Wochen-ID: $s');
    final id = WeekId(int.parse(m.group(1)!), int.parse(m.group(2)!));
    if (id.week < 1 || id.week > 53 || WeekId.fromDate(id.monday) != id) {
      throw FormatException('Ungültige Wochen-ID: $s');
    }
    return id;
  }

  /// Montag dieser Woche (UTC-Datum ohne Uhrzeit).
  DateTime get monday {
    final jan4 = DateTime.utc(year, 1, 4);
    final mondayWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
    return mondayWeek1.add(Duration(days: 7 * (week - 1)));
  }

  WeekId get next => WeekId.fromDate(monday.add(const Duration(days: 7)));

  WeekId get previous => WeekId.fromDate(monday.subtract(const Duration(days: 7)));

  @override
  String toString() => '$year-W${week.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) => other is WeekId && other.year == year && other.week == week;

  @override
  int get hashCode => Object.hash(year, week);

  @override
  int compareTo(WeekId other) => year != other.year ? year - other.year : week - other.week;
}

class Dinner {
  const Dinner({
    required this.date,
    required this.recipeId,
    this.state = DinnerState.planned,
    this.costChf = 0,
    this.changeReason,
    this.rating,
  });

  /// ISO-Datum JJJJ-MM-TT.
  final String date;
  final String recipeId;
  final DinnerState state;
  final double costChf;
  final ChangeReason? changeReason;
  final Rating? rating;

  factory Dinner.fromJson(Json j) => Dinner(
        date: j['date'] as String,
        recipeId: j['recipeId'] as String,
        state: fromWire(DinnerState.values, j['state']) ?? DinnerState.planned,
        costChf: toDouble(j['costChf']),
        changeReason: fromWire(ChangeReason.values, j['changeReason']),
        rating: fromWire(Rating.values, j['rating']),
      );

  Json toJson() => {
        'date': date,
        'recipeId': recipeId,
        'state': state.wire,
        'costChf': costChf,
        'changeReason': changeReason?.wire,
        'rating': rating?.wire,
      };
}

class ShoppingItem {
  const ShoppingItem({
    required this.ingredientId,
    required this.productLabel,
    required this.packs,
    required this.priceChf,
    required this.category,
    this.checked = false,
    this.custom = false,
  });

  /// null bei eigenen Artikeln.
  final String? ingredientId;
  final String productLabel;
  final int packs;

  /// Preis einer Packung.
  final double priceChf;
  final Category category;
  final bool checked;
  final bool custom;

  double get lineTotalChf => packs * priceChf;

  factory ShoppingItem.fromJson(Json j) => ShoppingItem(
        ingredientId: j['ingredientId'] as String?,
        productLabel: j['productLabel'] as String? ?? '',
        packs: toInt(j['packs'], 1),
        priceChf: toDouble(j['priceChf']),
        category: fromWire(Category.values, j['category']) ?? Category.sonstiges,
        checked: j['checked'] == true,
        custom: j['custom'] == true,
      );

  Json toJson() => {
        'ingredientId': ingredientId,
        'productLabel': productLabel,
        'packs': packs,
        'priceChf': priceChf,
        'category': category.wire,
        'checked': checked,
        'custom': custom,
      };
}

/// `households/{id}/weeks/{weekId}`
class Week {
  const Week({
    required this.weekId,
    required this.status,
    required this.shoppingDate,
    required this.budgetChf,
    required this.dinners,
    required this.shoppingList,
    required this.totalChf,
    required this.residualValueChf,
    required this.overBudgetChf,
    this.actualReceiptChf,
    this.generatedAt,
    required this.plannerVersion,
  });

  final WeekId weekId;
  final WeekStatus status;

  /// ISO-Datum JJJJ-MM-TT.
  final String shoppingDate;
  final double budgetChf;
  final List<Dinner> dinners;
  final List<ShoppingItem> shoppingList;
  final double totalChf;
  final double residualValueChf;
  final double overBudgetChf;
  final double? actualReceiptChf;
  final DateTime? generatedAt;
  final String plannerVersion;

  factory Week.fromJson(Json j) => Week(
        weekId: WeekId.parse(j['weekId'] as String),
        status: fromWire(WeekStatus.values, j['status']) ?? WeekStatus.open,
        shoppingDate: j['shoppingDate'] as String? ?? '',
        budgetChf: toDouble(j['budgetChf']),
        dinners: [
          for (final d in (j['dinners'] as List? ?? const []))
            Dinner.fromJson(Map<String, dynamic>.from(d as Map)),
        ],
        shoppingList: [
          for (final s in (j['shoppingList'] as List? ?? const []))
            ShoppingItem.fromJson(Map<String, dynamic>.from(s as Map)),
        ],
        totalChf: toDouble(j['totalChf']),
        residualValueChf: toDouble(j['residualValueChf']),
        overBudgetChf: toDouble(j['overBudgetChf']),
        actualReceiptChf: toDoubleOrNull(j['actualReceiptChf']),
        generatedAt: toDateTime(j['generatedAt']),
        plannerVersion: j['plannerVersion'] as String? ?? '',
      );

  Json toJson() => {
        'weekId': weekId.toString(),
        'status': status.wire,
        'shoppingDate': shoppingDate,
        'budgetChf': budgetChf,
        'dinners': [for (final d in dinners) d.toJson()],
        'shoppingList': [for (final s in shoppingList) s.toJson()],
        'totalChf': totalChf,
        'residualValueChf': residualValueChf,
        'overBudgetChf': overBudgetChf,
        'actualReceiptChf': actualReceiptChf,
        'plannerVersion': plannerVersion,
      };
}
