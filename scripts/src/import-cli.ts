/**
 * Lädt die Stammdaten aus /data (oder --dir) in den Firestore-Emulator.
 *   npm run import                     (Emulator muss laufen: npm run emulators im Root)
 *   npm run import -- --dir ../data --format json
 *
 * Ablauf: laden → validieren (bei Fehlern Abbruch) → schreiben.
 * Schreibt ingredients, products, recipes und config/app. Dokumente in diesen
 * Stammdaten-Sammlungen, die nicht mehr in den Daten vorkommen, werden gelöscht.
 *
 * Sicherheit: Bis zur Auslieferung (M7) läuft der Import nur gegen den
 * Emulator und nur mit einem demo-Projekt. Ein Projekt mit Präfix «demo-» kann
 * keine echten Firebase-Ressourcen erreichen.
 */
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Firestore, WriteBatch } from 'firebase-admin/firestore';
import { parseArgs } from './args';
import { Dataset, loadDataset, LoadError } from './load';
import { printReport } from './report';
import { validateDataset } from './validate';
import { productId } from '../../functions/src/model/types';

const BATCH_LIMIT = 400;

export function toDocuments(ds: Dataset): Map<string, Map<string, Record<string, unknown>>> {
  const cols = new Map<string, Map<string, Record<string, unknown>>>();
  cols.set('ingredients', new Map(ds.ingredients.map((i) => [i.id, { ...i }])));
  cols.set('products', new Map(ds.products.map((p) => [productId(p.retailer, p.ingredientId), { ...p }])));
  cols.set('recipes', new Map(ds.recipes.map((r) => [r.id, { ...r }])));
  cols.set('config', new Map(ds.config ? [['app', { ...ds.config }]] : []));
  return cols;
}

async function writeAll(db: Firestore, cols: ReturnType<typeof toDocuments>): Promise<void> {
  let batch: WriteBatch = db.batch();
  let ops = 0;
  const flush = async () => {
    if (ops > 0) await batch.commit();
    batch = db.batch();
    ops = 0;
  };
  const add = async (fn: (b: WriteBatch) => void) => {
    fn(batch);
    if (++ops >= BATCH_LIMIT) await flush();
  };

  for (const [col, docs] of cols) {
    const existing = await db.collection(col).listDocuments();
    let removed = 0;
    for (const ref of existing) {
      if (!docs.has(ref.id)) {
        await add((b) => b.delete(ref));
        removed++;
      }
    }
    for (const [id, data] of docs) {
      await add((b) => b.set(db.collection(col).doc(id), data));
    }
    console.log(`  ${col}: ${docs.size} geschrieben${removed ? `, ${removed} veraltete gelöscht` : ''}`);
  }
  await flush();
}

async function main(): Promise<number> {
  const args = parseArgs(process.argv.slice(2));

  if (!args.project.startsWith('demo-')) {
    console.error(
      `FEHLER: Import in «${args.project}» abgelehnt. Bis zur Auslieferung (M7) nur in den Emulator mit einem demo-Projekt.`,
    );
    return 1;
  }
  process.env.FIRESTORE_EMULATOR_HOST ??= '127.0.0.1:8080';

  let ds: Dataset;
  try {
    ds = loadDataset(args.dir, args.format);
  } catch (e) {
    if (e instanceof LoadError) {
      console.error(`FEHLER: ${e.message}`);
      return 1;
    }
    throw e;
  }
  const result = validateDataset(ds);
  printReport(result, args.dir);
  if (result.errors.length > 0) {
    console.error('Import abgebrochen: zuerst die Fehler beheben.');
    return 1;
  }

  console.log(`Schreibe in Firestore-Emulator ${process.env.FIRESTORE_EMULATOR_HOST}, Projekt ${args.project} …`);
  const app = initializeApp({ projectId: args.project });
  const db = getFirestore(app);
  try {
    await writeAll(db, toDocuments(ds));
  } catch (e) {
    console.error(`FEHLER beim Schreiben: ${(e as Error).message}`);
    console.error('Läuft der Emulator? Im Repo-Root: npm run emulators');
    return 1;
  }
  console.log('Import abgeschlossen.');
  return 0;
}

if (require.main === module) {
  main().then((code) => {
    process.exitCode = code;
  });
}
