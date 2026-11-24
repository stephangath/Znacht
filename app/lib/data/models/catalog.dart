import 'enums.dart';
import 'json.dart';

/// `ingredients/{ingredientId}`
class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.isStaple,
    this.allergens = const [],
    this.dietTags = const [],
  });

  final String id;
  final String name;
  final Category category;
  final Unit unit;
  final bool isStaple;
  final List<Allergen> allergens;
  final List<DietTag> dietTags;

  factory Ingredient.fromJson(Json j) => Ingredient(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        category: fromWire(Category.values, j['category']) ?? Category.sonstiges,
        unit: fromWire(Unit.values, j['unit']) ?? Unit.stk,
        isStaple: j['isStaple'] == true,
        allergens: listFromWire(Allergen.values, j['allergens']),
        dietTags: listFromWire(DietTag.values, j['dietTags']),
      );

  Json toJson() => {
        'id': id,
        'name': name,
        'category': category.wire,
        'unit': unit.wire,
        'isStaple': isStaple,
        'allergens': toWireList(allergens),
        'dietTags': toWireList(dietTags),
      };
}

/// `products/{retailer}_{ingredientId}`
class Product {
  const Product({
    required this.retailer,
    required this.ingredientId,
    required this.label,
    required this.packSize,
    required this.priceChf,
    required this.priceCheckedAt,
    required this.isDummy,
  });

  final Retailer retailer;
  final String ingredientId;
  final String label;

  /// In der Einheit der Zutat (g, ml oder Stück).
  final double packSize;
  final double priceChf;

  /// ISO-Datum JJJJ-MM-TT.
  final String priceCheckedAt;
  final bool isDummy;

  static String docId(Retailer retailer, String ingredientId) => '${retailer.wire}_$ingredientId';

  String get id => docId(retailer, ingredientId);

  /// Preis pro Einheit (A1: Packungspreis ÷ Packungsgrösse).
  double get unitPriceChf => packSize > 0 ? priceChf / packSize : 0;

  factory Product.fromJson(Json j) => Product(
        retailer: fromWire(Retailer.values, j['retailer']) ?? Retailer.migros,
        ingredientId: j['ingredientId'] as String,
        label: j['label'] as String? ?? '',
        packSize: toDouble(j['packSize']),
        priceChf: toDouble(j['priceChf']),
        priceCheckedAt: j['priceCheckedAt'] as String? ?? '',
        isDummy: j['isDummy'] == true,
      );

  Json toJson() => {
        'retailer': retailer.wire,
        'ingredientId': ingredientId,
        'label': label,
        'packSize': packSize,
        'priceChf': priceChf,
        'priceCheckedAt': priceCheckedAt,
        'isDummy': isDummy,
      };
}

class RecipeIngredient {
  const RecipeIngredient({required this.ingredientId, required this.qty});

  final String ingredientId;

  /// Menge für 2 Portionen, in der Einheit der Zutat.
  final double qty;

  factory RecipeIngredient.fromJson(Json j) =>
      RecipeIngredient(ingredientId: j['ingredientId'] as String, qty: toDouble(j['qty']));

  Json toJson() => {'ingredientId': ingredientId, 'qty': qty};
}

class RecipeStep {
  const RecipeStep({required this.text, required this.minutes});

  final String text;
  final int minutes;

  factory RecipeStep.fromJson(Json j) =>
      RecipeStep(text: j['text'] as String? ?? '', minutes: toInt(j['minutes']));

  Json toJson() => {'text': text, 'minutes': minutes};
}

/// `recipes/{recipeId}` – auf 2 Portionen normiert.
class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.prepMinutes,
    required this.appliances,
    required this.dietTags,
    required this.kidFriendly,
    required this.mainProtein,
    required this.cuisine,
    required this.ingredients,
    required this.steps,
    this.imagePath,
    this.isDummy = false,
  });

  static const int baseServings = 2;

  final String id;
  final String title;
  final int prepMinutes;
  final List<Appliance> appliances;
  final List<DietTag> dietTags;
  final bool kidFriendly;
  final MainProtein mainProtein;
  final String cuisine;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final String? imagePath;
  final bool isDummy;

  int get servings => baseServings;

  factory Recipe.fromJson(Json j) => Recipe(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        prepMinutes: toInt(j['prepMinutes']),
        appliances: listFromWire(Appliance.values, j['appliances']),
        dietTags: listFromWire(DietTag.values, j['dietTags']),
        kidFriendly: j['kidFriendly'] == true,
        mainProtein: fromWire(MainProtein.values, j['mainProtein']) ?? MainProtein.none,
        cuisine: j['cuisine'] as String? ?? '',
        ingredients: [
          for (final i in (j['ingredients'] as List? ?? const []))
            RecipeIngredient.fromJson(Map<String, dynamic>.from(i as Map)),
        ],
        steps: [
          for (final s in (j['steps'] as List? ?? const []))
            RecipeStep.fromJson(Map<String, dynamic>.from(s as Map)),
        ],
        imagePath: j['imagePath'] as String?,
        isDummy: j['isDummy'] == true,
      );

  Json toJson() => {
        'id': id,
        'title': title,
        'servings': servings,
        'prepMinutes': prepMinutes,
        'appliances': toWireList(appliances),
        'dietTags': toWireList(dietTags),
        'kidFriendly': kidFriendly,
        'mainProtein': mainProtein.wire,
        'cuisine': cuisine,
        'ingredients': [for (final i in ingredients) i.toJson()],
        'steps': [for (final s in steps) s.toJson()],
        'imagePath': imagePath,
        'isDummy': isDummy,
      };
}

/// `config/app`
class AppConfig {
  const AppConfig({
    required this.enabledRetailers,
    required this.feedbackPromptAfterDays,
    required this.testMode,
  });

  static const fallback = AppConfig(
    enabledRetailers: [Retailer.migros],
    feedbackPromptAfterDays: 7,
    testMode: true,
  );

  final List<Retailer> enabledRetailers;
  final int feedbackPromptAfterDays;
  final bool testMode;

  factory AppConfig.fromJson(Json j) => AppConfig(
        enabledRetailers: listFromWire(Retailer.values, j['enabledRetailers']),
        feedbackPromptAfterDays: toInt(j['feedbackPromptAfterDays'], 7),
        testMode: j['testMode'] != false,
      );

  Json toJson() => {
        'enabledRetailers': toWireList(enabledRetailers),
        'feedbackPromptAfterDays': feedbackPromptAfterDays,
        'testMode': testMode,
      };
}
