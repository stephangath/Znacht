import { resolve } from 'path';
import type { DataFormat } from './load';

export interface CliArgs {
  dir: string;
  format?: DataFormat;
  project: string;
  flags: Set<string>;
}

/** Einfache Argumente: --dir <pfad> --format csv|json --project <id> und Schalter wie --verbose. */
export function parseArgs(argv: string[]): CliArgs {
  const args: CliArgs = {
    dir: resolve(__dirname, '../../data'),
    project: 'demo-znacht',
    flags: new Set(),
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const next = () => {
      const v = argv[++i];
      if (v === undefined) throw new Error(`${a} braucht einen Wert`);
      return v;
    };
    if (a === '--dir') args.dir = resolve(next());
    else if (a === '--format') {
      const f = next();
      if (f !== 'csv' && f !== 'json') throw new Error('--format muss csv oder json sein');
      args.format = f;
    } else if (a === '--project') args.project = next();
    else if (a.startsWith('--')) args.flags.add(a.slice(2));
    else throw new Error(`Unbekanntes Argument: ${a}`);
  }
  return args;
}
