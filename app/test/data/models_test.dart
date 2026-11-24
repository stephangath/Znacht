import 'package:flutter_test/flutter_test.dart';
import 'package:znacht/data/models/models.dart';

void main() {
  test('Rezept aus dem Beispiel der Spezifikation', () {
    final r = Recipe.fromJson({
      'id': 'ofengemuese-feta',
      'title': 'Ofengemüse mit Feta',
      'servings': 2,
      'prepMinutes': 35,
      'appliances': ['oven'],
      'dietTags': ['vegetarian'],
      'kidFriendly': true,
      'mainProtein': 'cheese',
      'cuisine': 'mediterran',
      'ingredients': [
        {'ingredientId': 'karotten', 'qty': 300},
        {'ingredientId': 'feta', 'qty': 150},
      ],
      'steps': [
        {'text': 'Ofen auf 200 °C vorheizen.', 'minutes': 5},
      ],
      'imagePath': 'recipes/ofengemuese-feta.jpg',
      'isDummy': true,
    });
    expect(r.appliances, [Appliance.oven]);
    expect(r.dietTags, [DietTag.vegetarian]);
    expect(r.mainProtein, MainProtein.cheese);
    expect(r.ingredients.first.qty, 300);
    expect(Recipe.fromJson(r.toJson()).toJson(), r.toJson());
  });

  test('Produkt: Stückpreis und Dokument-ID', () {
    final p = Product.fromJson({
      'retailer': 'migros',
      'ingredientId': 'karotten',
      'label': 'Karotten 1 kg',
      'packSize': 1000,
      'priceChf': 2.2,
      'priceCheckedAt': '2026-11-20',
      'isDummy': true,
    });
    expect(p.id, 'migros_karotten');
    expect(p.unitPriceChf, closeTo(0.0022, 1e-9));
  });

  test('Haushalt: Wire-Werte, Einkaufstag und Budget-Startwert', () {
    final h = Household.fromJson('uid1', {
      'memberUids': ['uid1'],
      'retailer': 'migros',
      'postalCode': '8004',
      'servings': 2,
      'cookingDays': [1, 2, 4, 5],
      'shoppingDay': 'auto',
      'budgetChf': 90,
      'diet': 'high_protein',
      'allergens': ['peanuts', 'unbekannt'],
      'painPoint': 'too_expensive',
      'testerName': 'Anna',
    });
    expect(h.diet, Diet.highProtein);
    expect(h.allergens, [Allergen.peanuts]);
    expect(h.shoppingDay, ShoppingDay.auto);
    expect(h.painPoint, PainPoint.tooExpensive);
    expect(h.toJson()['diet'], 'high_protein');
    expect(h.toJson()['shoppingDay'], 'auto');
    expect(Household.fromJson('x', {'shoppingDay': 6}).shoppingDay, const FixedShoppingDay(6));
    expect(Household.defaultBudgetFor(2), 120);
  });

  test('Haushalt mitten im Onboarding (Felder fehlen)', () {
    final h = Household.fromJson('uid1', {'memberUids': ['uid1']});
    expect(h.retailer, isNull);
    expect(h.budgetChf, isNull);
    expect(h.toJson().containsKey('retailer'), isFalse);
  });

  test('Woche aus dem Beispiel der Spezifikation', () {
    final json = {
      'weekId': '2026-W48',
      'status': 'open',
      'shoppingDate': '2026-11-23',
      'budgetChf': 90,
      'dinners': [
        {
          'date': '2026-11-24',
          'recipeId': 'ofengemuese-feta',
          'state': 'planned',
          'costChf': 7.8,
          'changeReason': null,
          'rating': null,
        },
      ],
      'shoppingList': [
        {
          'ingredientId': 'karotten',
          'productLabel': 'Karotten 1 kg',
          'packs': 2,
          'priceChf': 2.2,
          'category': 'gemuese',
          'checked': false,
          'custom': false,
        },
      ],
      'totalChf': 84.3,
      'residualValueChf': 6.1,
      'overBudgetChf': 0,
      'actualReceiptChf': null,
      'plannerVersion': '1.0.0',
    };
    final w = Week.fromJson(json);
    expect(w.weekId.toString(), '2026-W48');
    expect(w.dinners.single.state, DinnerState.planned);
    expect(w.shoppingList.single.lineTotalChf, closeTo(4.4, 1e-9));
    expect(w.toJson(), json);
  });

  test('Konfiguration', () {
    final c = AppConfig.fromJson({
      'enabledRetailers': ['migros'],
      'feedbackPromptAfterDays': 7,
      'testMode': true,
    });
    expect(c.enabledRetailers, [Retailer.migros]);
    expect(c.toJson()['enabledRetailers'], ['migros']);
  });
}
