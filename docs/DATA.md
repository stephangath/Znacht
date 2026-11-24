# Stammdaten: Format und Regeln

Die Stammdaten liegen in `/data`. Das Import-Skript lädt sie in Firestore (siehe Datenmodell in `docs/SPEC.md`, Abschnitt 4).

Bis M6 nur in den lokalen Emulator.

```bash
npm run data:validate   # prüfen
npm run data:import     # prüfen und in den laufenden Emulator laden
```

Die Daten aus M1 sind **Dummy-Daten** (`isDummy: true`) mit runden Fantasiepreisen. Vor dem Test werden sie durch echte Migros-Referenzpreise und geprüfte Rezepte ersetzt (SPEC Abschnitt 10).

## Dateien (CSV, führende Quelle)

Alle Dateien sind UTF-8 und kommagetrennt, mit Kopfzeile. Listenfelder werden mit `|` getrennt (z. B. `vegan|vegetarian`). Wahrheitswerte schreibt man als `true` / `false`. Ein leeres Feld bedeutet: leere Liste bzw. `null`.

| Datei | Spalten |
| --- | --- |
| `ingredients.csv` | `id, name, category, unit, isStaple, allergens, dietTags` |
| `products.csv` | `retailer, ingredientId, label, packSize, priceChf, priceCheckedAt, isDummy` |
| `recipes.csv` | `id, title, servings, prepMinutes, appliances, dietTags, kidFriendly, mainProtein, cuisine, imagePath, isDummy` |
| `recipe_ingredients.csv` | `recipeId, ingredientId, qty` (Menge für 2 Portionen, in der Einheit der Zutat) |
| `recipe_steps.csv` | `recipeId, stepNo, text, minutes` |
| `config.json` | Inhalt von `config/app`: `enabledRetailers`, `feedbackPromptAfterDays`, `testMode` |

Wer die Daten in einer Tabelle pflegt (Google Sheets, Excel), legt dafür fünf Blätter an und exportiert jedes Blatt als CSV unter dem Namen oben.

## Alternative: JSON

Statt der CSV-Dateien gehen auch `ingredients.json`, `products.json` und `recipes.json`. Jede Datei enthält ein Array von Dokumenten genau im Firestore-Format aus der SPEC. Rezepte enthalten ihre `ingredients` und `steps` direkt. Das Skript erkennt das Format selbst, oder man gibt es an:

```bash
npm --prefix scripts run validate -- --dir pfad/zu/daten --format json
```

## Wertebereiche

Die Wertebereiche sind in `functions/src/model/types.ts` definiert.

- `unit`: `g`, `ml`, `stk`
- `category` (Reihenfolge der Einkaufsliste): `gemuese`, `milchprodukte`, `eier_tofu`, `fleisch`, `fisch`, `teigwaren_reis`, `konserven`, `backen_gewuerze`, `snacks_nuesse`, `sonstiges`
- `allergens`: `gluten`, `lactose`, `nuts`, `peanuts`, `egg`, `fish`, `shellfish`, `soy`, `celery`, `mustard`, `sesame`
- `retailer`: `migros`, `coop`, `aldi`, `lidl`, `denner`
- `appliances`: `oven`, `stove`, `steamer`, `airfryer`, `microwave`
- `mainProtein`: `chicken`, `beef`, `pork`, `fish`, `egg`, `cheese`, `tofu`, `legumes`, `none`
- `cuisine`: `schweiz`, `italienisch`, `mediterran`, `asiatisch`, `indisch`, `mexikanisch`, `orientalisch`

## Ernährungs-Tags

**Zutaten** tragen nur diese Tags:
- Pflanzlich: `vegan|vegetarian`
- Milchprodukte und Eier: `vegetarian`
- Fisch und Meeresfrüchte: `pescetarian`
- Fleisch: keine Tags

**Rezepte** müssen genau die Tags tragen, die sich aus ihren Zutaten ergeben (die Validierung prüft das):
- `vegan`: alle Zutaten vegan
- `vegetarian`: alle Zutaten vegetarisch
- `pescetarian`: alle Zutaten vegetarisch oder pescetarisch, mindestens eine mit Fisch

Zusätzlich darf ein Rezept frei `high_protein` tragen.

Der Planer (ab M2) lässt für «pescetarisch» Rezepte mit `pescetarian`, `vegetarian` oder `vegan` zu. Für «vegetarisch» lässt er `vegetarian` zu, das auch alle veganen Rezepte tragen.

Die Allergene eines Rezepts sind die Vereinigung der Allergene seiner Zutaten. Rezepte haben kein eigenes Allergen-Feld.

## Weitere Prüfungen

**Fehler** (blockieren den Import):
- IDs fehlen, kommen doppelt vor oder enthalten unzulässige Zeichen
- Verweise auf unbekannte Zutaten oder Rezepte
- `servings` ist nicht 2
- Mengen, Packungsgrössen oder Preise sind nicht grösser als 0
- Preis endet nicht auf 0 oder 5 Rappen
- Datum ist nicht im Format `JJJJ-MM-TT`
- Ein Wert liegt ausserhalb der Wertebereiche
- «ß» in Namen, Titeln oder Schritten
- Eine Zutat des Grundvorrats (Salz, Pfeffer, Öl, Mehl, Zucker, Essig, Bouillon) fehlt oder ist nicht als `isStaple` markiert
- Ein aktivierter Händler hat keine Produkte

**Warnungen**:
- Einem Rezept fehlt bei einem Händler ein Produkt; der Planer lässt das Rezept dort weg
- Die Summe der Schritte liegt deutlich über `prepMinutes`
- Ein aktivierter Händler hat weniger als 21 vollständig belegte Rezepte

## Sicherheit

`npm run data:import` schreibt nur in Projekte mit dem Präfix `demo-` (Standard `demo-znacht`). Solche Projekte existieren nur im Emulator. Den Import in ein echtes Projekt bereitet M7 vor.
