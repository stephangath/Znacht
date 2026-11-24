/**
 * Einstiegspunkt der Cloud Functions.
 *
 * M1: noch keine Functions. Ab M2 folgen hier die Callables aus src/api
 * (generateWeek, swapOptions, applyChange, markShopped, markCooked) und der
 * Scheduler rolloverWeek. Die Planungslogik bleibt in src/planner ohne
 * Firebase-Abhängigkeit.
 */
import { setGlobalOptions } from 'firebase-functions/v2';

export const REGION = 'europe-west6';

setGlobalOptions({ region: REGION, maxInstances: 10 });
