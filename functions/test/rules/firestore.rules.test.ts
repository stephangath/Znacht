/**
 * Tests der Firestore Security Rules gegen den lokalen Emulator.
 * Start aus dem Repo-Root: `npm run test:rules`
 */
import { readFileSync } from 'fs';
import { resolve } from 'path';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc, collection, deleteDoc, doc, getDoc, serverTimestamp, setDoc, setLogLevel, updateDoc,
} from 'firebase/firestore';

let env: RulesTestEnvironment;

const ALICE = 'alice';
const BOB = 'bob';

function household(uid: string) {
  return {
    memberUids: [uid],
    retailer: 'migros',
    postalCode: '8004',
    servings: 2,
    budgetChf: 90,
  };
}

beforeAll(async () => {
  // Abgelehnte Schreibzugriffe sind hier erwartet; Warnungen nicht ausgeben.
  setLogLevel('error');
  env = await initializeTestEnvironment({
    projectId: 'demo-znacht-rules',
    firestore: {
      rules: readFileSync(resolve(__dirname, '../../../firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

afterAll(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'recipes/r1'), { id: 'r1', title: 'Test' });
    await setDoc(doc(db, 'config/app'), { enabledRetailers: ['migros'] });
    await setDoc(doc(db, `households/${BOB}`), household(BOB));
    await setDoc(doc(db, `households/${BOB}/weeks/2026-W48`), { weekId: '2026-W48', status: 'open' });
  });
});

describe('Stammdaten und config', () => {
  test('eingeloggt lesbar', async () => {
    const db = env.authenticatedContext(ALICE).firestore();
    await assertSucceeds(getDoc(doc(db, 'recipes/r1')));
    await assertSucceeds(getDoc(doc(db, 'config/app')));
  });

  test('ohne Login nicht lesbar', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'recipes/r1')));
  });

  test('für Clients nie schreibbar', async () => {
    const db = env.authenticatedContext(ALICE).firestore();
    await assertFails(setDoc(doc(db, 'recipes/r2'), { id: 'r2' }));
    await assertFails(setDoc(doc(db, 'ingredients/x'), { id: 'x' }));
    await assertFails(setDoc(doc(db, 'products/migros_x'), { label: 'x' }));
    await assertFails(updateDoc(doc(db, 'config/app'), { testMode: false }));
  });
});

describe('Haushalt', () => {
  test('eigenen Haushalt anlegen, lesen, ändern, löschen', async () => {
    const db = env.authenticatedContext(ALICE).firestore();
    const ref = doc(db, `households/${ALICE}`);
    await assertSucceeds(setDoc(ref, household(ALICE)));
    await assertSucceeds(getDoc(ref));
    await assertSucceeds(updateDoc(ref, { budgetChf: 120, cookingDays: [1, 3, 5] }));
    await assertSucceeds(deleteDoc(ref));
  });

  test('Haushalt unter fremder ID anlegen verboten', async () => {
    const db = env.authenticatedContext(ALICE).firestore();
    await assertFails(setDoc(doc(db, 'households/irgendwas'), household(ALICE)));
  });

  test('fremden Haushalt weder lesen noch ändern', async () => {
    const db = env.authenticatedContext(ALICE).firestore();
    await assertFails(getDoc(doc(db, `households/${BOB}`)));
    await assertFails(updateDoc(doc(db, `households/${BOB}`), { budgetChf: 50 }));
    await assertFails(getDoc(doc(db, `households/${BOB}/weeks/2026-W48`)));
  });

  test('memberUids nicht änderbar', async () => {
    const db = env.authenticatedContext(BOB).firestore();
    await assertFails(updateDoc(doc(db, `households/${BOB}`), { memberUids: [BOB, ALICE] }));
  });

  test('ungültige Werte werden abgelehnt', async () => {
    const db = env.authenticatedContext(BOB).firestore();
    const ref = doc(db, `households/${BOB}`);
    await assertFails(updateDoc(ref, { budgetChf: 500 }));
    await assertFails(updateDoc(ref, { postalCode: '0123' }));
    await assertFails(updateDoc(ref, { servings: 9 }));
    await assertFails(updateDoc(ref, { unbekanntesFeld: true }));
  });

  test('Vorrat und Wochen nur für Mitglieder', async () => {
    const bob = env.authenticatedContext(BOB).firestore();
    await assertSucceeds(setDoc(doc(bob, `households/${BOB}/pantry/reis`),
      { ingredientId: 'reis', isStapleOverride: null, leftoverQty: 400 }));
    await assertFails(setDoc(doc(bob, `households/${BOB}/pantry/reis`),
      { ingredientId: 'pasta', leftoverQty: 400 }));
    await assertSucceeds(updateDoc(doc(bob, `households/${BOB}/weeks/2026-W48`), { totalChf: 80 }));

    const alice = env.authenticatedContext(ALICE).firestore();
    await assertFails(setDoc(doc(alice, `households/${BOB}/pantry/reis`), { ingredientId: 'reis' }));
  });
});

describe('feedback und events', () => {
  test('eigene Einträge anlegen erlaubt', async () => {
    const db = env.authenticatedContext(BOB).firestore();
    await assertSucceeds(addDoc(collection(db, 'feedback'), {
      householdId: BOB, uid: BOB, screen: 'week', type: 'free_text',
      text: 'Gefällt mir', answers: null, createdAt: serverTimestamp(),
    }));
    await assertSucceeds(addDoc(collection(db, 'events'), {
      householdId: BOB, uid: BOB, name: 'app_opened', props: null, createdAt: serverTimestamp(),
    }));
  });

  test('Ereignis vor Anlegen des Haushalts erlaubt (eigene UID)', async () => {
    const db = env.authenticatedContext(ALICE).firestore();
    await assertSucceeds(addDoc(collection(db, 'events'), {
      householdId: ALICE, uid: ALICE, name: 'onboarding_step_viewed',
      props: { step: 1 }, createdAt: serverTimestamp(),
    }));
  });

  test('fremde UID oder fremder Haushalt verboten', async () => {
    const db = env.authenticatedContext(ALICE).firestore();
    await assertFails(addDoc(collection(db, 'events'), {
      householdId: ALICE, uid: BOB, name: 'x', props: null, createdAt: serverTimestamp(),
    }));
    await assertFails(addDoc(collection(db, 'feedback'), {
      householdId: BOB, uid: ALICE, screen: 'week', type: 'free_text',
      text: 'x', answers: null, createdAt: serverTimestamp(),
    }));
  });

  test('nicht lesbar', async () => {
    let id = '';
    await env.withSecurityRulesDisabled(async (ctx) => {
      const ref = await addDoc(collection(ctx.firestore(), 'feedback'), { uid: BOB, householdId: BOB });
      id = ref.id;
    });
    const db = env.authenticatedContext(BOB).firestore();
    await assertFails(getDoc(doc(db, `feedback/${id}`)));
  });
});
