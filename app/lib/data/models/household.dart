import 'enums.dart';
import 'json.dart';

/// Einkaufstag: `auto` (Tag vor dem ersten Kochabend) oder fester Wochentag 1–7.
sealed class ShoppingDay {
  const ShoppingDay();

  static const auto = AutoShoppingDay();

  factory ShoppingDay.fromJson(Object? v) =>
      v is num && v >= 1 && v <= 7 ? FixedShoppingDay(v.toInt()) : const AutoShoppingDay();

  Object toJson();
}

class AutoShoppingDay extends ShoppingDay {
  const AutoShoppingDay();
  @override
  Object toJson() => 'auto';
  @override
  bool operator ==(Object other) => other is AutoShoppingDay;
  @override
  int get hashCode => 0;
}

class FixedShoppingDay extends ShoppingDay {
  const FixedShoppingDay(this.weekday) : assert(weekday >= 1 && weekday <= 7);

  /// 1 = Montag … 7 = Sonntag
  final int weekday;
  @override
  Object toJson() => weekday;
  @override
  bool operator ==(Object other) => other is FixedShoppingDay && other.weekday == weekday;
  @override
  int get hashCode => weekday;
}

/// `households/{householdId}` – householdId = UID des anlegenden Kontos.
///
/// Während des Onboardings sind noch nicht alle Felder gesetzt; fehlende
/// Felder erhalten beim Lesen Standardwerte.
class Household {
  const Household({
    required this.id,
    required this.memberUids,
    this.retailer,
    this.postalCode,
    this.servings = 2,
    this.kidFriendly = false,
    this.cookingDays = const [],
    this.shoppingDay = ShoppingDay.auto,
    this.budgetChf,
    this.cheapestMode = false,
    this.diet = Diet.omnivore,
    this.allergens = const [],
    this.avoidIngredientIds = const [],
    this.appliances = const [],
    this.hiddenRecipeIds = const [],
    this.favoriteRecipeIds = const [],
    this.painPoint,
    this.testerName,
    this.createdAt,
  });

  final String id;
  final List<String> memberUids;
  final Retailer? retailer;
  final String? postalCode;
  final int servings;
  final bool kidFriendly;

  /// 1 = Montag … 7 = Sonntag
  final List<int> cookingDays;
  final ShoppingDay shoppingDay;
  final double? budgetChf;
  final bool cheapestMode;
  final Diet diet;
  final List<Allergen> allergens;
  final List<String> avoidIngredientIds;
  final List<Appliance> appliances;
  final List<String> hiddenRecipeIds;
  final List<String> favoriteRecipeIds;
  final PainPoint? painPoint;
  final String? testerName;
  final DateTime? createdAt;

  /// Startwert des Budgets nach A10: 60 + 30 × Personen.
  static double defaultBudgetFor(int persons) => 60 + 30.0 * persons;

  factory Household.fromJson(String id, Json j) => Household(
        id: id,
        memberUids: toStringList(j['memberUids']),
        retailer: fromWire(Retailer.values, j['retailer']),
        postalCode: j['postalCode'] as String?,
        servings: toInt(j['servings'], 2),
        kidFriendly: j['kidFriendly'] == true,
        cookingDays: toIntList(j['cookingDays']),
        shoppingDay: ShoppingDay.fromJson(j['shoppingDay']),
        budgetChf: toDoubleOrNull(j['budgetChf']),
        cheapestMode: j['cheapestMode'] == true,
        diet: fromWire(Diet.values, j['diet']) ?? Diet.omnivore,
        allergens: listFromWire(Allergen.values, j['allergens']),
        avoidIngredientIds: toStringList(j['avoidIngredientIds']),
        appliances: listFromWire(Appliance.values, j['appliances']),
        hiddenRecipeIds: toStringList(j['hiddenRecipeIds']),
        favoriteRecipeIds: toStringList(j['favoriteRecipeIds']),
        painPoint: fromWire(PainPoint.values, j['painPoint']),
        testerName: j['testerName'] as String?,
        createdAt: toDateTime(j['createdAt']),
      );

  /// Ohne `createdAt`: das setzt das Repository als Server-Zeitstempel.
  Json toJson() => {
        'memberUids': memberUids,
        if (retailer != null) 'retailer': retailer!.wire,
        if (postalCode != null) 'postalCode': postalCode,
        'servings': servings,
        'kidFriendly': kidFriendly,
        'cookingDays': cookingDays,
        'shoppingDay': shoppingDay.toJson(),
        if (budgetChf != null) 'budgetChf': budgetChf,
        'cheapestMode': cheapestMode,
        'diet': diet.wire,
        'allergens': toWireList(allergens),
        'avoidIngredientIds': avoidIngredientIds,
        'appliances': toWireList(appliances),
        'hiddenRecipeIds': hiddenRecipeIds,
        'favoriteRecipeIds': favoriteRecipeIds,
        'painPoint': painPoint?.wire,
        'testerName': testerName,
      };
}

/// `households/{id}/pantry/{ingredientId}`
class PantryItem {
  const PantryItem({
    required this.ingredientId,
    this.isStapleOverride,
    this.leftoverQty,
    this.updatedAt,
  });

  final String ingredientId;

  /// null = Standard der Zutat; false = Grundvorrat abgewählt; true = als Grundvorrat behandeln.
  final bool? isStapleOverride;

  /// Packungsrest aus früheren Wochen; null = «vorhanden, Menge egal».
  final double? leftoverQty;
  final DateTime? updatedAt;

  factory PantryItem.fromJson(Json j) => PantryItem(
        ingredientId: j['ingredientId'] as String,
        isStapleOverride: j['isStapleOverride'] as bool?,
        leftoverQty: toDoubleOrNull(j['leftoverQty']),
        updatedAt: toDateTime(j['updatedAt']),
      );

  Json toJson() => {
        'ingredientId': ingredientId,
        'isStapleOverride': isStapleOverride,
        'leftoverQty': leftoverQty,
      };
}
