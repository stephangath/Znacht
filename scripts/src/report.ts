import type { ValidationResult } from './validate';

export function printReport(result: ValidationResult, source: string): void {
  const { stats } = result;
  const products = Object.entries(stats.productsByRetailer)
    .map(([r, n]) => `${r} ${n}`)
    .join(', ');
  console.log(`Quelle: ${source}`);
  console.log(
    `Zutaten: ${stats.ingredients} · Rezepte: ${stats.recipes} · Produkte: ${products || '–'}`,
  );
  console.log(`Dummy-Daten: ${stats.dummyProducts} Produkte, ${stats.dummyRecipes} Rezepte`);
  for (const w of result.warnings) console.log(`  Warnung: ${w}`);
  for (const e of result.errors) console.log(`  FEHLER:  ${e}`);
  console.log(
    result.errors.length === 0
      ? `OK – keine Fehler, ${result.warnings.length} Warnung(en).`
      : `${result.errors.length} Fehler, ${result.warnings.length} Warnung(en).`,
  );
}
