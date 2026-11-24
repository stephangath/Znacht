/**
 * Lädt Stammdaten aus CSV- oder JSON-Dateien in ein einheitliches Format.
 * Formate siehe docs/DATA.md.
 *
 * Der Loader prüft nur die Syntax (Datei vorhanden, Zahl lesbar). Inhaltliche
 * Prüfungen macht validate.ts. Damit die Validierung alle Fehler auf einmal
 * melden kann, behält der Loader Rohwerte bei, wo eine Umwandlung scheitert.
 */
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';
import { parse } from 'csv-parse/sync';
import type { AppConfig, Ingredient, Product, Recipe } from '../../functions/src/model/types';

export interface Dataset {
  ingredients: Ingredient[];
  products: Product[];
  recipes: Recipe[];
  config: AppConfig | null;
}

export type DataFormat = 'csv' | 'json';

export class LoadError extends Error {}

type Row = Record<string, string>;

function readCsv(dir: string, file: string): Row[] {
  const path = join(dir, file);
  if (!existsSync(path)) throw new LoadError(`Datei fehlt: ${path}`);
  return parse(readFileSync(path, 'utf8'), {
    columns: true,
    skip_empty_lines: true,
    trim: true,
    bom: true,
  }) as Row[];
}

function readJson<T>(dir: string, file: string): T {
  const path = join(dir, file);
  if (!existsSync(path)) throw new LoadError(`Datei fehlt: ${path}`);
  try {
    return JSON.parse(readFileSync(path, 'utf8')) as T;
  } catch (e) {
    throw new LoadError(`${path}: ungültiges JSON (${(e as Error).message})`);
  }
}

/** «a|b|c» → ['a','b','c']; leer → [] */
export function list(value: string | undefined): string[] {
  if (value === undefined || value.trim() === '') return [];
  return value.split('|').map((s) => s.trim()).filter((s) => s !== '');
}

/** «true»/«false» → boolean; sonst Rohwert (die Validierung meldet ihn). */
function bool(value: string | undefined): boolean {
  if (value === 'true') return true;
  if (value === 'false') return false;
  return value as unknown as boolean;
}

/** Zahl; nicht lesbare Werte bleiben NaN (die Validierung meldet sie). */
function num(value: string | undefined): number {
  if (value === undefined || value.trim() === '') return NaN;
  return Number(value);
}

function nullable(value: string | undefined): string | null {
  return value === undefined || value.trim() === '' ? null : value;
}

export function detectFormat(dir: string): DataFormat {
  if (existsSync(join(dir, 'ingredients.csv'))) return 'csv';
  if (existsSync(join(dir, 'ingredients.json'))) return 'json';
  throw new LoadError(`Weder ingredients.csv noch ingredients.json in ${dir} gefunden.`);
}

function loadConfig(dir: string): AppConfig | null {
  return existsSync(join(dir, 'config.json')) ? readJson<AppConfig>(dir, 'config.json') : null;
}

export function loadCsv(dir: string): Dataset {
  const ingredients: Ingredient[] = readCsv(dir, 'ingredients.csv').map((r) => ({
    id: r.id,
    name: r.name,
    category: r.category as Ingredient['category'],
    unit: r.unit as Ingredient['unit'],
    isStaple: bool(r.isStaple),
    allergens: list(r.allergens) as Ingredient['allergens'],
    dietTags: list(r.dietTags) as Ingredient['dietTags'],
  }));

  const products: Product[] = readCsv(dir, 'products.csv').map((r) => ({
    retailer: r.retailer as Product['retailer'],
    ingredientId: r.ingredientId,
    label: r.label,
    packSize: num(r.packSize),
    priceChf: num(r.priceChf),
    priceCheckedAt: r.priceCheckedAt,
    isDummy: bool(r.isDummy),
  }));

  const recipeRows = readCsv(dir, 'recipes.csv');
  const ingredientRows = readCsv(dir, 'recipe_ingredients.csv');
  const stepRows = readCsv(dir, 'recipe_steps.csv');

  const recipes: Recipe[] = recipeRows.map((r) => ({
    id: r.id,
    title: r.title,
    servings: num(r.servings) as 2,
    prepMinutes: num(r.prepMinutes),
    appliances: list(r.appliances) as Recipe['appliances'],
    dietTags: list(r.dietTags) as Recipe['dietTags'],
    kidFriendly: bool(r.kidFriendly),
    mainProtein: r.mainProtein as Recipe['mainProtein'],
    cuisine: r.cuisine as Recipe['cuisine'],
    ingredients: ingredientRows
      .filter((i) => i.recipeId === r.id)
      .map((i) => ({ ingredientId: i.ingredientId, qty: num(i.qty) })),
    steps: stepRows
      .filter((s) => s.recipeId === r.id)
      .sort((a, b) => num(a.stepNo) - num(b.stepNo))
      .map((s) => ({ text: s.text, minutes: num(s.minutes) })),
    imagePath: nullable(r.imagePath),
    isDummy: bool(r.isDummy),
  }));

  // Zeilen, die auf kein Rezept zeigen, als Pseudo-Rezept-Fehler sichtbar machen.
  const recipeIds = new Set(recipeRows.map((r) => r.id));
  const orphanIngredients = ingredientRows.filter((i) => !recipeIds.has(i.recipeId));
  const orphanSteps = stepRows.filter((s) => !recipeIds.has(s.recipeId));
  if (orphanIngredients.length > 0 || orphanSteps.length > 0) {
    const ids = [...new Set([...orphanIngredients, ...orphanSteps].map((r) => r.recipeId))];
    throw new LoadError(
      `recipe_ingredients.csv/recipe_steps.csv verweisen auf unbekannte Rezepte: ${ids.join(', ')}`,
    );
  }

  return { ingredients, products, recipes, config: loadConfig(dir) };
}

export function loadJson(dir: string): Dataset {
  return {
    ingredients: readJson<Ingredient[]>(dir, 'ingredients.json'),
    products: readJson<Product[]>(dir, 'products.json'),
    recipes: readJson<Recipe[]>(dir, 'recipes.json'),
    config: loadConfig(dir),
  };
}

export function loadDataset(dir: string, format?: DataFormat): Dataset {
  const f = format ?? detectFormat(dir);
  return f === 'csv' ? loadCsv(dir) : loadJson(dir);
}
