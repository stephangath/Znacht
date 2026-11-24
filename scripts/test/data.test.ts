import { mkdtempSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join, resolve } from 'path';
import { detectFormat, list, loadCsv, loadDataset, loadJson, Dataset } from '../src/load';
import { deriveDietTags, validateDataset } from '../src/validate';
import { toDocuments } from '../src/import-cli';

const DATA_DIR = resolve(__dirname, '../../data');

function clone(ds: Dataset): Dataset {
  return JSON.parse(JSON.stringify(ds)) as Dataset;
}

function errorsOf(ds: Dataset): string[] {
  return validateDataset(ds).errors;
}

describe('Stammdaten in /data', () => {
  const ds = loadCsv(DATA_DIR);

  test('Umfang für M1: 40 Zutaten, 30 Rezepte, Migros und Coop', () => {
    expect(ds.ingredients).toHaveLength(40);
    expect(ds.recipes).toHaveLength(30);
    const retailers = new Set(ds.products.map((p) => p.retailer));
    expect([...retailers].sort()).toEqual(['coop', 'migros']);
  });

  test('alles ist als Dummy markiert', () => {
    expect(ds.products.every((p) => p.isDummy === true)).toBe(true);
    expect(ds.recipes.every((r) => r.isDummy === true)).toBe(true);
  });

  test('Validierung meldet keine Fehler', () => {
    expect(validateDataset(ds).errors).toEqual([]);
  });

  test('Rezept wird vollständig aus den drei CSV-Dateien zusammengesetzt', () => {
    const r = ds.recipes.find((x) => x.id === 'ofengemuese-feta')!;
    expect(r.servings).toBe(2);
    expect(r.ingredients).toContainEqual({ ingredientId: 'feta', qty: 150 });
    expect(r.steps[0]).toEqual({ text: 'Ofen auf 200 °C vorheizen.', minutes: 5 });
    expect(r.imagePath).toBeNull();
  });
});

describe('CSV und JSON', () => {
  test('JSON im Firestore-Format ergibt dieselben Daten wie CSV', () => {
    const csv = loadCsv(DATA_DIR);
    const dir = mkdtempSync(join(tmpdir(), 'znacht-json-'));
    writeFileSync(join(dir, 'ingredients.json'), JSON.stringify(csv.ingredients));
    writeFileSync(join(dir, 'products.json'), JSON.stringify(csv.products));
    writeFileSync(join(dir, 'recipes.json'), JSON.stringify(csv.recipes));
    writeFileSync(join(dir, 'config.json'), JSON.stringify(csv.config));
    expect(detectFormat(dir)).toBe('json');
    expect(loadJson(dir)).toEqual(csv);
    expect(loadDataset(dir)).toEqual(csv);
  });

  test('Listenfelder werden mit | getrennt', () => {
    expect(list('vegan|vegetarian')).toEqual(['vegan', 'vegetarian']);
    expect(list('')).toEqual([]);
    expect(list(undefined)).toEqual([]);
  });
});

describe('Validierung erkennt Fehler', () => {
  const base = loadCsv(DATA_DIR);

  test('unbekannte Zutat im Rezept', () => {
    const ds = clone(base);
    ds.recipes[0].ingredients.push({ ingredientId: 'einhorn', qty: 1 });
    expect(errorsOf(ds).join('\n')).toMatch(/unbekannte Zutat «einhorn»/);
  });

  test('falsches Ernährungs-Tag (Hackfleisch als vegetarisch)', () => {
    const ds = clone(base);
    const r = ds.recipes.find((x) => x.id === 'spaghetti-bolognese')!;
    r.dietTags = ['vegetarian'];
    expect(errorsOf(ds).join('\n')).toMatch(/als «vegetarian» markiert/);
  });

  test('fehlendes Ernährungs-Tag', () => {
    const ds = clone(base);
    const r = ds.recipes.find((x) => x.id === 'linsen-dal')!;
    r.dietTags = ['vegetarian'];
    expect(errorsOf(ds).join('\n')).toMatch(/Zutaten sind «vegan», das Tag fehlt/);
  });

  test('Portionen ungleich 2', () => {
    const ds = clone(base);
    (ds.recipes[0] as { servings: number }).servings = 4;
    expect(errorsOf(ds).join('\n')).toMatch(/servings muss 2 sein/);
  });

  test('doppeltes Produkt und ungültiger Preis', () => {
    const ds = clone(base);
    ds.products.push({ ...ds.products[0] });
    ds.products[1].priceChf = 2.33;
    ds.products[2].priceChf = NaN;
    const errors = errorsOf(ds).join('\n');
    expect(errors).toMatch(/mehrfach vorhanden/);
    expect(errors).toMatch(/endet nicht auf 0 oder 5 Rappen/);
    expect(errors).toMatch(/priceChf muss eine Zahl > 0 sein/);
  });

  test('Grundvorrat fehlt oder ist nicht markiert', () => {
    const ds = clone(base);
    ds.ingredients.find((i) => i.id === 'salz')!.isStaple = false;
    expect(errorsOf(ds).join('\n')).toMatch(/«salz» muss isStaple = true/);
  });

  test('unbekannte Werte in Aufzählungen', () => {
    const ds = clone(base);
    (ds.ingredients[10] as { unit: string }).unit = 'kg';
    (ds.ingredients[11] as { allergens: string[] }).allergens = ['laktose'];
    (ds.recipes[3] as { appliances: string[] }).appliances = ['grill'];
    const errors = errorsOf(ds).join('\n');
    expect(errors).toMatch(/unbekannte Einheit «kg»/);
    expect(errors).toMatch(/unbekanntes Allergen «laktose»/);
    expect(errors).toMatch(/unbekanntes Gerät «grill»/);
  });

  test('ß statt ss', () => {
    const ds = clone(base);
    ds.recipes[0].title = 'Grosse Pfanne mit Soße';
    expect(errorsOf(ds).join('\n')).toMatch(/«ß» im Titel/);
  });

  test('fehlendes Produkt beim Händler ist eine Warnung', () => {
    const ds = clone(base);
    ds.products = ds.products.filter((p) => !(p.retailer === 'coop' && p.ingredientId === 'feta'));
    const result = validateDataset(ds);
    expect(result.errors).toEqual([]);
    expect(result.warnings.join('\n')).toMatch(/bei coop fehlen Produkte für feta/);
  });

  test('aktivierter Händler ohne Produkte', () => {
    const ds = clone(base);
    ds.config!.enabledRetailers = ['migros', 'denner'];
    expect(errorsOf(ds).join('\n')).toMatch(/«denner» ist aktiviert, hat aber keine Produkte/);
  });
});

describe('Ableitung der Ernährungs-Tags', () => {
  const ing = (id: string, dietTags: string[]) => ({
    id, name: id, category: 'gemuese', unit: 'g', isStaple: false, allergens: [], dietTags,
  }) as never;

  test('Fisch mit Milchprodukt ist pescetarisch, nicht vegetarisch', () => {
    const tags = deriveDietTags([ing('lachs', ['pescetarian']), ing('rahm', ['vegetarian'])]);
    expect([...tags]).toEqual(['pescetarian']);
  });

  test('rein pflanzlich ist vegan und vegetarisch', () => {
    const tags = deriveDietTags([ing('reis', ['vegan', 'vegetarian'])]);
    expect([...tags].sort()).toEqual(['vegan', 'vegetarian']);
  });

  test('Fleisch hat keine Tags', () => {
    expect(deriveDietTags([ing('poulet', []), ing('reis', ['vegan', 'vegetarian'])]).size).toBe(0);
  });
});

describe('Firestore-Dokumente', () => {
  test('Produkt-IDs {retailer}_{ingredientId}, config/app', () => {
    const cols = toDocuments(loadCsv(DATA_DIR));
    expect(cols.get('products')!.has('migros_karotten')).toBe(true);
    expect(cols.get('products')!.has('coop_karotten')).toBe(true);
    expect(cols.get('config')!.get('app')).toEqual({
      enabledRetailers: ['migros'], feedbackPromptAfterDays: 7, testMode: true,
    });
    expect(cols.get('recipes')!.size).toBe(30);
  });
});
