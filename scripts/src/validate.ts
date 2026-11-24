/**
 * Inhaltliche Prüfung der Stammdaten. Regeln siehe docs/DATA.md.
 * Fehler blockieren den Import, Warnungen nicht.
 */
import {
  ALLERGENS, APPLIANCES, CATEGORIES, CUISINES, DIET_TAGS, INGREDIENT_DIET_TAGS,
  MAIN_PROTEINS, RETAILERS, UNITS, productId,
} from '../../functions/src/model/types';
import type { DietTag, Ingredient } from '../../functions/src/model/types';
import type { Dataset } from './load';

export interface ValidationResult {
  errors: string[];
  warnings: string[];
  stats: {
    ingredients: number;
    recipes: number;
    productsByRetailer: Record<string, number>;
    dummyProducts: number;
    dummyRecipes: number;
  };
}

/** Grundvorrat nach SPEC Abschnitt 2. */
export const REQUIRED_STAPLES = ['salz', 'pfeffer', 'oel', 'mehl', 'zucker', 'essig', 'bouillon'];

const ID_PATTERN = /^[a-z0-9][a-z0-9_-]*$/;
const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

function isOneOf<T extends string>(values: readonly T[], v: unknown): v is T {
  return typeof v === 'string' && (values as readonly string[]).includes(v);
}

function duplicates<T>(items: T[]): T[] {
  const seen = new Set<T>();
  const dup = new Set<T>();
  for (const i of items) (seen.has(i) ? dup : seen).add(i);
  return [...dup];
}

function isValidDate(s: unknown): boolean {
  if (typeof s !== 'string' || !DATE_PATTERN.test(s)) return false;
  const d = new Date(`${s}T00:00:00Z`);
  return !Number.isNaN(d.getTime()) && d.toISOString().startsWith(s);
}

/** Preise in der Schweiz enden auf 0 oder 5 Rappen. */
function isRappenPrice(v: number): boolean {
  return Math.abs(Math.round(v * 20) - v * 20) < 1e-6;
}

/**
 * Ernährungsformen, die ein Rezept nach seinen Zutaten erfüllt:
 * - vegan: alle Zutaten vegan
 * - vegetarian: alle Zutaten vegetarisch
 * - pescetarian: alle Zutaten vegetarisch oder pescetarisch, mindestens eine
 *   nur pescetarisch (also mit Fisch). Rein vegetarische Rezepte tragen das
 *   Tag nicht; der Planer lässt sie für Pescetarier trotzdem zu.
 */
export function deriveDietTags(ingredients: Ingredient[]): Set<DietTag> {
  const tags = new Set<DietTag>();
  const has = (i: Ingredient, t: DietTag) => i.dietTags.includes(t);
  if (ingredients.every((i) => has(i, 'vegan'))) tags.add('vegan');
  if (ingredients.every((i) => has(i, 'vegetarian'))) tags.add('vegetarian');
  if (
    ingredients.every((i) => has(i, 'vegetarian') || has(i, 'pescetarian'))
    && ingredients.some((i) => !has(i, 'vegetarian'))
  ) {
    tags.add('pescetarian');
  }
  return tags;
}

export function validateDataset(ds: Dataset): ValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];
  const err = (m: string) => errors.push(m);
  const warn = (m: string) => warnings.push(m);

  // ---------- Zutaten ----------
  const ingredientById = new Map<string, Ingredient>();
  for (const d of duplicates(ds.ingredients.map((i) => i.id))) err(`Zutat «${d}»: ID mehrfach vorhanden`);

  for (const i of ds.ingredients) {
    const p = `Zutat «${i.id}»`;
    ingredientById.set(i.id, i);
    if (typeof i.id !== 'string' || !ID_PATTERN.test(i.id)) err(`${p}: ungültige ID (nur a–z, 0–9, _ und -)`);
    if (typeof i.name !== 'string' || i.name.trim() === '') err(`${p}: Name fehlt`);
    if (typeof i.name === 'string' && i.name.includes('ß')) err(`${p}: «ß» im Namen, bitte «ss» verwenden`);
    if (!isOneOf(CATEGORIES, i.category)) err(`${p}: unbekannte Kategorie «${i.category}»`);
    if (!isOneOf(UNITS, i.unit)) err(`${p}: unbekannte Einheit «${i.unit}»`);
    if (typeof i.isStaple !== 'boolean') err(`${p}: isStaple muss true oder false sein`);
    for (const a of i.allergens ?? []) if (!isOneOf(ALLERGENS, a)) err(`${p}: unbekanntes Allergen «${a}»`);
    for (const t of i.dietTags ?? []) {
      if (!isOneOf(INGREDIENT_DIET_TAGS, t)) err(`${p}: Ernährungs-Tag «${t}» ist für Zutaten nicht erlaubt`);
    }
    if (i.dietTags?.includes('vegan') && !i.dietTags.includes('vegetarian')) {
      err(`${p}: vegan ohne vegetarian`);
    }
    if (i.dietTags?.includes('pescetarian') && i.dietTags.includes('vegetarian')) {
      err(`${p}: pescetarian ist nur für Fisch und Meeresfrüchte (nicht zusammen mit vegetarian)`);
    }
  }

  for (const s of REQUIRED_STAPLES) {
    const i = ingredientById.get(s);
    if (!i) err(`Grundvorrat: Zutat «${s}» fehlt`);
    else if (i.isStaple !== true) err(`Grundvorrat: Zutat «${s}» muss isStaple = true haben`);
  }
  for (const i of ds.ingredients) {
    if (i.isStaple === true && !REQUIRED_STAPLES.includes(i.id)) {
      warn(`Zutat «${i.id}»: isStaple = true, gehört aber nicht zum Grundvorrat der Spezifikation`);
    }
  }

  // ---------- Produkte ----------
  const productKeys = new Set<string>();
  for (const d of duplicates(ds.products.map((p) => `${p.retailer}_${p.ingredientId}`))) {
    err(`Produkt «${d}»: mehrfach vorhanden (pro Händler und Zutat nur ein Produkt)`);
  }
  for (const pr of ds.products) {
    const key = `${pr.retailer}_${pr.ingredientId}`;
    const p = `Produkt «${key}»`;
    productKeys.add(key);
    if (!isOneOf(RETAILERS, pr.retailer)) err(`${p}: unbekannter Händler «${pr.retailer}»`);
    if (!ingredientById.has(pr.ingredientId)) err(`${p}: unbekannte Zutat «${pr.ingredientId}»`);
    if (typeof pr.label !== 'string' || pr.label.trim() === '') err(`${p}: Bezeichnung fehlt`);
    if (typeof pr.packSize !== 'number' || !Number.isFinite(pr.packSize) || pr.packSize <= 0) {
      err(`${p}: packSize muss eine Zahl > 0 sein`);
    }
    if (typeof pr.priceChf !== 'number' || !Number.isFinite(pr.priceChf) || pr.priceChf <= 0) {
      err(`${p}: priceChf muss eine Zahl > 0 sein`);
    } else {
      if (!isRappenPrice(pr.priceChf)) err(`${p}: Preis ${pr.priceChf} endet nicht auf 0 oder 5 Rappen`);
      if (pr.priceChf > 200) warn(`${p}: Preis CHF ${pr.priceChf.toFixed(2)} ungewöhnlich hoch`);
    }
    if (!isValidDate(pr.priceCheckedAt)) err(`${p}: priceCheckedAt muss ein Datum JJJJ-MM-TT sein`);
    if (typeof pr.isDummy !== 'boolean') err(`${p}: isDummy muss true oder false sein`);
  }

  // ---------- Rezepte ----------
  for (const d of duplicates(ds.recipes.map((r) => r.id))) err(`Rezept «${d}»: ID mehrfach vorhanden`);

  const retailersWithProducts = [...new Set(ds.products.map((p) => p.retailer))];

  for (const r of ds.recipes) {
    const p = `Rezept «${r.id}»`;
    if (typeof r.id !== 'string' || !ID_PATTERN.test(r.id)) err(`${p}: ungültige ID (nur a–z, 0–9, _ und -)`);
    if (typeof r.title !== 'string' || r.title.trim() === '') err(`${p}: Titel fehlt`);
    if (typeof r.title === 'string' && r.title.includes('ß')) err(`${p}: «ß» im Titel, bitte «ss» verwenden`);
    if (r.servings !== 2) err(`${p}: servings muss 2 sein (Rezepte sind auf 2 Portionen normiert)`);
    if (!Number.isInteger(r.prepMinutes) || r.prepMinutes < 1 || r.prepMinutes > 300) {
      err(`${p}: prepMinutes muss eine ganze Zahl zwischen 1 und 300 sein`);
    }
    for (const a of r.appliances ?? []) if (!isOneOf(APPLIANCES, a)) err(`${p}: unbekanntes Gerät «${a}»`);
    for (const t of r.dietTags ?? []) if (!isOneOf(DIET_TAGS, t)) err(`${p}: unbekanntes Ernährungs-Tag «${t}»`);
    if (typeof r.kidFriendly !== 'boolean') err(`${p}: kidFriendly muss true oder false sein`);
    if (!isOneOf(MAIN_PROTEINS, r.mainProtein)) err(`${p}: unbekanntes mainProtein «${r.mainProtein}»`);
    if (!isOneOf(CUISINES, r.cuisine)) err(`${p}: unbekannte Küche «${r.cuisine}»`);
    if (r.imagePath !== null && (typeof r.imagePath !== 'string' || r.imagePath.trim() === '')) {
      err(`${p}: imagePath muss leer (null) oder ein Pfad sein`);
    }
    if (typeof r.isDummy !== 'boolean') err(`${p}: isDummy muss true oder false sein`);

    // Zutaten
    if (!Array.isArray(r.ingredients) || r.ingredients.length === 0) err(`${p}: keine Zutaten`);
    const ris = Array.isArray(r.ingredients) ? r.ingredients : [];
    for (const d of duplicates(ris.map((i) => i.ingredientId))) err(`${p}: Zutat «${d}» mehrfach aufgeführt`);
    const known: Ingredient[] = [];
    for (const ri of ris) {
      const ing = ingredientById.get(ri.ingredientId);
      if (!ing) err(`${p}: unbekannte Zutat «${ri.ingredientId}»`);
      else known.push(ing);
      if (typeof ri.qty !== 'number' || !Number.isFinite(ri.qty) || ri.qty <= 0) {
        err(`${p}: Menge für «${ri.ingredientId}» muss eine Zahl > 0 sein`);
      }
    }

    // Ernährungs-Tags müssen genau zu den Zutaten passen.
    if (known.length === ris.length && known.length > 0) {
      const derived = deriveDietTags(known);
      for (const t of ['vegan', 'vegetarian', 'pescetarian'] as DietTag[]) {
        const claimed = (r.dietTags ?? []).includes(t);
        if (claimed && !derived.has(t)) {
          const offenders = known.filter((i) => !i.dietTags.includes(t)).map((i) => i.id);
          err(`${p}: als «${t}» markiert, aber nicht alle Zutaten passen (${offenders.join(', ') || 'kein Fisch'})`);
        }
        if (!claimed && derived.has(t)) err(`${p}: Zutaten sind «${t}», das Tag fehlt aber`);
      }
    }

    // Schritte
    if (!Array.isArray(r.steps) || r.steps.length === 0) err(`${p}: keine Schritte`);
    const steps = Array.isArray(r.steps) ? r.steps : [];
    steps.forEach((s, idx) => {
      if (typeof s.text !== 'string' || s.text.trim() === '') err(`${p}: Schritt ${idx + 1} ohne Text`);
      if (typeof s.text === 'string' && s.text.includes('ß')) err(`${p}: Schritt ${idx + 1} enthält «ß»`);
      if (!Number.isInteger(s.minutes) || s.minutes < 0) err(`${p}: Schritt ${idx + 1} braucht Minuten ≥ 0`);
    });
    const stepTotal = steps.reduce((sum, s) => sum + (Number.isFinite(s.minutes) ? s.minutes : 0), 0);
    if (Number.isInteger(r.prepMinutes) && stepTotal > r.prepMinutes + 15) {
      warn(`${p}: Summe der Schritte (${stepTotal} min) deutlich über prepMinutes (${r.prepMinutes} min)`);
    }

    // Produkte pro Händler: fehlende Produkte filtern das Rezept beim Planen aus.
    for (const ret of retailersWithProducts) {
      const missing = ris
        .map((i) => i.ingredientId)
        .filter((id) => ingredientById.has(id) && !productKeys.has(productId(ret, id)));
      if (missing.length > 0) {
        warn(`${p}: bei ${ret} fehlen Produkte für ${missing.join(', ')} – Rezept wird dort nicht geplant`);
      }
    }
  }

  // ---------- Konfiguration ----------
  const cfg = ds.config;
  if (!cfg) {
    err('config.json fehlt');
  } else {
    if (!Array.isArray(cfg.enabledRetailers) || cfg.enabledRetailers.length === 0) {
      err('config: enabledRetailers braucht mindestens einen Händler');
    } else {
      for (const ret of cfg.enabledRetailers) {
        if (!isOneOf(RETAILERS, ret)) {
          err(`config: unbekannter Händler «${ret}»`);
          continue;
        }
        const withProducts = ds.ingredients.filter((i) => productKeys.has(productId(ret, i.id)));
        if (withProducts.length === 0) err(`config: Händler «${ret}» ist aktiviert, hat aber keine Produkte`);
        const plannable = ds.recipes.filter((r) => r.ingredients.every((i) => productKeys.has(productId(ret, i.ingredientId))));
        if (plannable.length < 21) {
          warn(`config: bei «${ret}» sind nur ${plannable.length} Rezepte vollständig mit Produkten belegt (Planer braucht bis zu 3 × 7)`);
        }
      }
    }
    if (!Number.isInteger(cfg.feedbackPromptAfterDays) || cfg.feedbackPromptAfterDays < 1) {
      err('config: feedbackPromptAfterDays muss eine ganze Zahl ≥ 1 sein');
    }
    if (typeof cfg.testMode !== 'boolean') err('config: testMode muss true oder false sein');
  }

  const productsByRetailer: Record<string, number> = {};
  for (const pr of ds.products) productsByRetailer[pr.retailer] = (productsByRetailer[pr.retailer] ?? 0) + 1;

  return {
    errors,
    warnings,
    stats: {
      ingredients: ds.ingredients.length,
      recipes: ds.recipes.length,
      productsByRetailer,
      dummyProducts: ds.products.filter((p) => p.isDummy === true).length,
      dummyRecipes: ds.recipes.filter((r) => r.isDummy === true).length,
    },
  };
}
