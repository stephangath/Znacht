/**
 * Prüft die Stammdaten in /data (oder --dir) und beendet sich mit Code 1 bei Fehlern.
 *   npm run validate
 *   npm run validate -- --dir ../data --format csv
 */
import { parseArgs } from './args';
import { loadDataset, LoadError } from './load';
import { printReport } from './report';
import { validateDataset } from './validate';

function main(): number {
  const args = parseArgs(process.argv.slice(2));
  try {
    const ds = loadDataset(args.dir, args.format);
    const result = validateDataset(ds);
    printReport(result, args.dir);
    return result.errors.length === 0 ? 0 : 1;
  } catch (e) {
    if (e instanceof LoadError) {
      console.error(`FEHLER: ${e.message}`);
      return 1;
    }
    throw e;
  }
}

process.exitCode = main();
