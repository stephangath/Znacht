/**
 * Datenmodell (Firestore), siehe docs/SPEC.md Abschnitt 4.
 *
 * Diese Datei hat keine Abhängigkeiten und wird von den Functions, dem Planer
 * und den Skripten in /scripts gemeinsam verwendet. Das Dart-Gegenstück liegt
 * in app/lib/data/models.
 */

// ---------- Wertebereiche ----------

export const UNITS = ['g', 'ml', 'stk'] as const;
export type Unit = (typeof UNITS)[number];

export const ALLERGENS = [
  'gluten', 'lactose', 'nuts', 'peanuts', 'egg', 'fish',
  'shellfish', 'soy', 'celery', 'mustard', 'sesame',
] as const;
export type Allergen = (typeof ALLERGENS)[number];

/**
 * Ernährungs-Tags. Zutaten tragen nur vegan/vegetarian/pescetarian.
 * Rezepte zusätzlich high_protein. Regeln siehe docs/DATA.md.
 */
export const DIET_TAGS = ['vegan', 'vegetarian', 'pescetarian', 'high_protein'] as const;
export type DietTag = (typeof DIET_TAGS)[number];
export const INGREDIENT_DIET_TAGS = ['vegan', 'vegetarian', 'pescetarian'] as const;

export const DIETS = ['omnivore', 'vegetarian', 'vegan', 'pescetarian', 'high_protein'] as const;
export type Diet = (typeof DIETS)[number];

export const RETAILERS = ['migros', 'coop', 'aldi', 'lidl', 'denner'] as const;
export type Retailer = (typeof RETAILERS)[number];

export const APPLIANCES = ['oven', 'stove', 'steamer', 'airfryer', 'microwave'] as const;
export type Appliance = (typeof APPLIANCES)[number];

/** Kategorien der Einkaufsliste, in Ladenreihenfolge. */
export const CATEGORIES = [
  'gemuese', 'milchprodukte', 'eier_tofu', 'fleisch', 'fisch',
  'teigwaren_reis', 'konserven', 'backen_gewuerze', 'snacks_nuesse', 'sonstiges',
] as const;
export type Category = (typeof CATEGORIES)[number];

export const MAIN_PROTEINS = [
  'chicken', 'beef', 'pork', 'fish', 'egg', 'cheese', 'tofu', 'legumes', 'none',
] as const;
export type MainProtein = (typeof MAIN_PROTEINS)[number];

export const CUISINES = [
  'schweiz', 'italienisch', 'mediterran', 'asiatisch', 'indisch',
  'mexikanisch', 'orientalisch',
] as const;
export type Cuisine = (typeof CUISINES)[number];

export const PAIN_POINTS = ['too_expensive', 'no_ideas', 'too_much_waste', 'no_time'] as const;
export type PainPoint = (typeof PAIN_POINTS)[number];

export const WEEK_STATUSES = ['open', 'locked', 'done'] as const;
export type WeekStatus = (typeof WEEK_STATUSES)[number];

export const DINNER_STATES = ['planned', 'cooked', 'eating_out', 'removed'] as const;
export type DinnerState = (typeof DINNER_STATES)[number];

export const CHANGE_REASONS = ['eating_out', 'not_in_the_mood', 'ingredient_missing', 'other'] as const;
export type ChangeReason = (typeof CHANGE_REASONS)[number];

export const FEEDBACK_TYPES = ['free_text', 'weekly_survey'] as const;
export type FeedbackType = (typeof FEEDBACK_TYPES)[number];

/** Zeitstempel: in Firestore ein Timestamp, in Fixtures ein ISO-String. */
export type TimestampLike = string | { toDate(): Date };

// ---------- Stammdaten ----------

/** `ingredients/{ingredientId}` */
export interface Ingredient {
  id: string;
  name: string;
  category: Category;
  unit: Unit;
  isStaple: boolean;
  allergens: Allergen[];
  dietTags: DietTag[];
}

/** `products/{retailer}_{ingredientId}` */
export interface Product {
  retailer: Retailer;
  ingredientId: string;
  label: string;
  /** In der Einheit der Zutat (g, ml oder Stück). */
  packSize: number;
  priceChf: number;
  /** ISO-Datum JJJJ-MM-TT */
  priceCheckedAt: string;
  isDummy: boolean;
}

export function productId(retailer: Retailer, ingredientId: string): string {
  return `${retailer}_${ingredientId}`;
}

export interface RecipeIngredient {
  ingredientId: string;
  /** Menge für `servings` (immer 2) Portionen, in der Einheit der Zutat. */
  qty: number;
}

export interface RecipeStep {
  text: string;
  minutes: number;
}

/** `recipes/{recipeId}` */
export interface Recipe {
  id: string;
  title: string;
  /** Rezepte sind auf 2 Portionen normiert. */
  servings: 2;
  prepMinutes: number;
  appliances: Appliance[];
  dietTags: DietTag[];
  kidFriendly: boolean;
  mainProtein: MainProtein;
  cuisine: Cuisine;
  ingredients: RecipeIngredient[];
  steps: RecipeStep[];
  imagePath: string | null;
  isDummy: boolean;
}

/** `config/app` */
export interface AppConfig {
  enabledRetailers: Retailer[];
  feedbackPromptAfterDays: number;
  testMode: boolean;
}

// ---------- Nutzerdaten ----------

/** `households/{householdId}` – householdId = UID des anlegenden Kontos. */
export interface Household {
  memberUids: string[];
  retailer: Retailer;
  postalCode: string;
  servings: number;
  kidFriendly: boolean;
  /** 1 = Montag … 7 = Sonntag */
  cookingDays: number[];
  /** 'auto' = Tag vor dem ersten Kochabend, sonst 1–7 */
  shoppingDay: 'auto' | number;
  budgetChf: number;
  cheapestMode: boolean;
  diet: Diet;
  allergens: Allergen[];
  avoidIngredientIds: string[];
  appliances: Appliance[];
  hiddenRecipeIds: string[];
  favoriteRecipeIds: string[];
  painPoint: PainPoint | null;
  testerName: string | null;
  createdAt: TimestampLike;
}

/** `households/{id}/pantry/{ingredientId}` */
export interface PantryItem {
  ingredientId: string;
  /** null = Standard der Zutat; false = Grundvorrat abgewählt; true = als Grundvorrat behandeln. */
  isStapleOverride: boolean | null;
  /** Packungsrest; null = «vorhanden, Menge egal». */
  leftoverQty: number | null;
  updatedAt: TimestampLike;
}

export interface Dinner {
  /** ISO-Datum JJJJ-MM-TT */
  date: string;
  recipeId: string;
  state: DinnerState;
  costChf: number;
  changeReason: ChangeReason | null;
  rating: 'up' | 'down' | null;
}

export interface ShoppingItem {
  /** null bei eigenen Artikeln */
  ingredientId: string | null;
  productLabel: string;
  packs: number;
  /** Preis einer Packung; Zeilensumme = packs × priceChf */
  priceChf: number;
  category: Category;
  checked: boolean;
  custom: boolean;
}

/** `households/{id}/weeks/{weekId}` – weekId im Format 2026-W48 */
export interface Week {
  weekId: string;
  status: WeekStatus;
  shoppingDate: string;
  budgetChf: number;
  dinners: Dinner[];
  shoppingList: ShoppingItem[];
  totalChf: number;
  residualValueChf: number;
  overBudgetChf: number;
  actualReceiptChf: number | null;
  generatedAt: TimestampLike;
  plannerVersion: string;
}

// ---------- Testauswertung ----------

/** `feedback/{autoId}` */
export interface FeedbackEntry {
  householdId: string;
  uid: string;
  screen: string;
  type: FeedbackType;
  text: string | null;
  answers: Record<string, unknown> | null;
  createdAt: TimestampLike;
}

/** `events/{autoId}` */
export interface AppEvent {
  householdId: string;
  uid: string;
  name: string;
  props: Record<string, unknown> | null;
  createdAt: TimestampLike;
}
