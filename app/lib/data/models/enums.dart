/// Wertebereiche des Datenmodells (SPEC Abschnitt 4).
/// Gegenstück zu functions/src/model/types.ts – Änderungen an beiden Orten nachführen.
library;

/// Enum mit einem Wert, wie er in Firestore steht.
abstract interface class WireEnum {
  String get wire;
}

enum Unit implements WireEnum {
  g('g'),
  ml('ml'),
  stk('stk');

  const Unit(this.wire);
  @override
  final String wire;
}

enum Allergen implements WireEnum {
  gluten('gluten'),
  lactose('lactose'),
  nuts('nuts'),
  peanuts('peanuts'),
  egg('egg'),
  fish('fish'),
  shellfish('shellfish'),
  soy('soy'),
  celery('celery'),
  mustard('mustard'),
  sesame('sesame');

  const Allergen(this.wire);
  @override
  final String wire;
}

enum DietTag implements WireEnum {
  vegan('vegan'),
  vegetarian('vegetarian'),
  pescetarian('pescetarian'),
  highProtein('high_protein');

  const DietTag(this.wire);
  @override
  final String wire;
}

enum Diet implements WireEnum {
  omnivore('omnivore'),
  vegetarian('vegetarian'),
  vegan('vegan'),
  pescetarian('pescetarian'),
  highProtein('high_protein');

  const Diet(this.wire);
  @override
  final String wire;
}

enum Retailer implements WireEnum {
  migros('migros'),
  coop('coop'),
  aldi('aldi'),
  lidl('lidl'),
  denner('denner');

  const Retailer(this.wire);
  @override
  final String wire;
}

enum Appliance implements WireEnum {
  oven('oven'),
  stove('stove'),
  steamer('steamer'),
  airfryer('airfryer'),
  microwave('microwave');

  const Appliance(this.wire);
  @override
  final String wire;
}

/// Kategorien in der Reihenfolge der Einkaufsliste.
enum Category implements WireEnum {
  gemuese('gemuese'),
  milchprodukte('milchprodukte'),
  eierTofu('eier_tofu'),
  fleisch('fleisch'),
  fisch('fisch'),
  teigwarenReis('teigwaren_reis'),
  konserven('konserven'),
  backenGewuerze('backen_gewuerze'),
  snacksNuesse('snacks_nuesse'),
  sonstiges('sonstiges');

  const Category(this.wire);
  @override
  final String wire;
}

enum MainProtein implements WireEnum {
  chicken('chicken'),
  beef('beef'),
  pork('pork'),
  fish('fish'),
  egg('egg'),
  cheese('cheese'),
  tofu('tofu'),
  legumes('legumes'),
  none('none');

  const MainProtein(this.wire);
  @override
  final String wire;
}

enum PainPoint implements WireEnum {
  tooExpensive('too_expensive'),
  noIdeas('no_ideas'),
  tooMuchWaste('too_much_waste'),
  noTime('no_time');

  const PainPoint(this.wire);
  @override
  final String wire;
}

enum WeekStatus implements WireEnum {
  open('open'),
  locked('locked'),
  done('done');

  const WeekStatus(this.wire);
  @override
  final String wire;
}

enum DinnerState implements WireEnum {
  planned('planned'),
  cooked('cooked'),
  eatingOut('eating_out'),
  removed('removed');

  const DinnerState(this.wire);
  @override
  final String wire;
}

/// Gründe für eine Änderung (A6).
enum ChangeReason implements WireEnum {
  eatingOut('eating_out'),
  notInTheMood('not_in_the_mood'),
  ingredientMissing('ingredient_missing'),
  other('other');

  const ChangeReason(this.wire);
  @override
  final String wire;
}

enum Rating implements WireEnum {
  up('up'),
  down('down');

  const Rating(this.wire);
  @override
  final String wire;
}

enum FeedbackType implements WireEnum {
  freeText('free_text'),
  weeklySurvey('weekly_survey');

  const FeedbackType(this.wire);
  @override
  final String wire;
}

/// Liest einen Wire-Wert; unbekannte Werte ergeben null.
T? fromWire<T extends WireEnum>(List<T> values, Object? wire) {
  for (final v in values) {
    if (v.wire == wire) return v;
  }
  return null;
}

/// Liest eine Liste von Wire-Werten; unbekannte Werte werden ausgelassen.
List<T> listFromWire<T extends WireEnum>(List<T> values, Object? wire) {
  if (wire is! List) return const [];
  return wire.map((w) => fromWire(values, w)).whereType<T>().toList(growable: false);
}

List<String> toWireList(Iterable<WireEnum> values) =>
    values.map((v) => v.wire).toList(growable: false);
