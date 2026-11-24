# Znacht – Spezifikation für die Umsetzung

Arbeitstitel «Znacht» (Name vor einem öffentlichen Launch markenrechtlich prüfen). Stand: 24.11.2026.

Diese Datei ist die Bauanleitung für Claude Code. Sie beschreibt, **was** die App tut, in welcher Reihenfolge gebaut wird und woran ein Meilenstein als fertig gilt. Wo das Verhalten des Vorbilds unbekannt war, steht eine ausdrückliche Annahme (Abschnitt 2). Annahmen dürfen beim Bauen nicht stillschweigend geändert werden; Abweichungen als Frage an Stephan zurückgeben.

---

## 0. Ziel der ersten Version: Web-Test mit Freunden und Familie

Die erste Version ist eine **Web-App (Flutter Web)**, die Stephan per Link an 10–30 Haushalte aus Freundes- und Familienkreis schickt. Sie nutzen die App 2–3 Wochen lang für ihre echten Abendessen und Einkäufe. Ziel ist Feedback zu drei Fragen:

1. Sind die Wochenpläne brauchbar, und kochen die Leute danach?
2. Stimmen die geschätzten Preise ungefähr mit dem Kassenbon überein?
3. Würden sie dafür zahlen, und wenn nicht, was fehlt?

Darum gilt für diese Version:
- **Drin:** Onboarding, Planer, Wochenplan, Rezepte, Einkaufsliste, Vorrat, Feedback-Funktion, einfache Nutzungszählung.
- **Nicht drin:** Paywall und Abos, Push-Mitteilungen, App-Store-Bewertung, Haushalt teilen, iOS- und Android-Builds.
- Der Code wird so gebaut, dass dieselbe Codebasis später ohne Umbau als iOS- und Android-App erscheinen kann (keine Web-only-Pakete im Kern, plattformspezifisches nur hinter Schnittstellen).

---

## 1. Produkt in einem Absatz

Die App plant für einen Schweizer Haushalt die Abendessen einer Woche so, dass der Einkauf beim gewählten Detailhändler unter einem selbst gesetzten Budget bleibt. Sie erstellt eine Einkaufsliste in ganzen Packungen, zieht vorhandene Vorräte ab und rechnet neu, wenn ein Gericht getauscht, verschoben oder durch «auswärts essen» ersetzt wird. Später finanziert über ein Abo mit Paywall nach dem Onboarding (Abschnitt 11).

**Nicht-Ziele (auch später vorerst nicht):** Bestellung beim Händler, Live-Preise, Aktionen, Frühstück und Mittagessen, Französisch und Italienisch, Rezeptimport aus Videos.

**Abgrenzung zum Vorbild:** Keine Namen, Texte, Grafiken, Farben oder Screen-Layouts von TapCook übernehmen. Gestaltung eigenständig. Keine erfundenen Erfahrungsberichte.

---

## 2. Annahmen (verbindlich)

| Nr. | Frage | Annahme |
| --- | --- | --- |
| A1 | Wie werden Kosten auf Gerichte verteilt? | Kosten pro Gericht = verwendete Menge × Stückpreis (Packungspreis ÷ Packungsgrösse). Wochentotal = Summe der ganzen Packungen auf der Einkaufsliste. Die Differenz wird als «Restwert» ausgewiesen. |
| A2 | Budget mit den Filtern nicht erreichbar? | Die App liefert den günstigsten möglichen Plan und zeigt einen Hinweis «CHF X über Budget» mit zwei Vorschlägen: weniger Kochabende oder Filter lockern. |
| A3 | Was zeigt die Reste-Warnung? | Liste der Zutaten, die nur für das entfernte Gericht gekauft wurden, mit Menge und Wert. Optionen: «Auf anderen Tag verschieben», «In den Vorrat übernehmen», «Trotzdem entfernen». |
| A4 | Wann ist ein Plan gesperrt? | Am Einkaufstag um 00:00 oder sobald der Nutzer «Eingekauft» tippt. Danach ändert Tauschen/Entfernen die Einkaufsliste nicht mehr, sondern löst A3 aus. Die nächste Woche öffnet 2 Tage vor ihrem Einkaufstag. |
| A5 | Häufigkeits-Regler bei den Essgewohnheiten | Schritt entfällt. |
| A6 | Gründe für eine Änderung | «Auswärts essen», «Keine Lust darauf», «Zutat fehlt», «Anderes». Nur «Auswärts essen» entfernt das Gericht; die anderen öffnen den Tausch-Dialog. Gründe werden gespeichert. |
| A7 | Zweck von «Storing it» | Tab «Vorrat ergänzen» in der Einkaufsliste: nach «Eingekauft» erscheinen Packungsreste, die voraussichtlich übrig bleiben, und werden mit einem Tipp in den Vorrat übernommen. |
| A8 | Navigation | Vier Tabs: **Woche**, **Einkauf**, **Küche**, **Profil**. Planungseinstellungen (Einkaufstag, Kochabende, Budget, Laden) liegen in der Woche hinter einem Einstellungs-Symbol. Auf breiten Bildschirmen (> 800 px) eine Seitenleiste statt Tabs unten. |
| A9 | Alternativen beim Tauschen | 6 Alternativen, je mit Zubereitungszeit und Preisänderung für die ganze Woche (+/- CHF). |
| A10 | Budget-Screen | Ein Screen: Schieberegler CHF 40–250 in 5er-Schritten, Startwert nach Haushaltsgrösse (60 + 30 × Personen), Schalter «Möglichst günstig». |

Weitere Festlegungen:

- **Wochenbeginn:** Montag. Wochen-ID im Format `2026-W48`.
- **Portionen:** Rezepte sind auf 2 Portionen normiert und werden linear skaliert. Packungen werden erst nach dem Skalieren aufgerundet.
- **Grundvorrat:** Salz, Pfeffer, Öl, Mehl, Zucker, Essig und Bouillon gelten standardmässig als vorhanden und erscheinen nie auf der Liste, solange der Nutzer sie im Vorrat nicht abwählt.
- **Händler:** Ein Hauptladen pro Haushalt. Im Onboarding erscheinen nur Händler aus der Konfiguration `enabledRetailers` (für den Test voraussichtlich nur Migros). Wechsel berechnet die laufende, nicht gesperrte Woche neu.
- **Preise:** Referenzpreise pro Händler, ohne Regionen. In der App immer als «geschätzt» gekennzeichnet.
- **Testversion:** Oben ein schmales Band «Testversion – dein Feedback hilft» mit Link zum Feedback.

---

## 3. Technik

| Bereich | Wahl |
| --- | --- |
| App | Flutter, **Web als erstes Ziel**; iOS und Android später aus derselben Codebasis |
| State/Navigation | Riverpod, go_router (URL-basiert, damit Neuladen im Browser die Seite behält) |
| Backend | Firebase: Auth, Firestore, Cloud Functions (2nd gen, TypeScript, Node 20), Hosting |
| Region | `europe-west6` (Zürich) für Firestore und Functions |
| Login | Anonym beim Start. Im Profil optional «Auf anderem Gerät nutzen» per E-Mail-Link (Firebase Email Link Sign-in), der das anonyme Konto verknüpft |
| Texte | ARB-Dateien, Locale `de_CH`; Schweizer Rechtschreibung (immer «ss», nie «ß»), Beträge als `CHF 12.50` |
| Darstellung | Mobile zuerst (die meisten Tester öffnen den Link am Handy); funktioniert auch am Desktop |
| Tests | Planer als reine TypeScript-Module mit Jest-Tests; Flutter Widget-Tests für Onboarding |
| Konfiguration | Firestore-Dokument `config/app`: `enabledRetailers`, `feedbackPromptAfterDays`, `testMode` |

### Repo-Struktur

```
/app                Flutter-App
  /lib/features/onboarding
  /lib/features/week
  /lib/features/shopping
  /lib/features/pantry
  /lib/features/profile
  /lib/features/feedback
  /lib/data         Firestore-Repositories, Modelle
  /l10n             ARB-Dateien
/functions          Cloud Functions (TypeScript)
  /src/planner      reine Planungslogik, ohne Firebase-Abhängigkeit
  /src/api          callable functions
  /test             Jest-Tests mit Fixtures
/data               Stammdaten (CSV oder JSON)
/scripts            Import und Validierung der Stammdaten, Export der Testauswertung
/docs/SPEC.md       diese Datei
```

---

## 4. Datenmodell (Firestore)

Stammdaten und `config` sind nur für Functions und Import-Skripte schreibbar, für eingeloggte Nutzer lesbar. Nutzerdaten nur für den eigenen Haushalt lesbar und schreibbar. `feedback` und `events` sind für Nutzer nur schreibbar (eigene Einträge), nicht lesbar.

### Stammdaten

**`ingredients/{ingredientId}`**
```json
{
  "id": "karotten",
  "name": "Karotten",
  "category": "gemuese",
  "unit": "g",
  "isStaple": false,
  "allergens": [],
  "dietTags": ["vegan", "vegetarian"]
}
```
`unit`: g | ml | stk. `allergens`: gluten | lactose | nuts | peanuts | egg | fish | shellfish | soy | celery | mustard | sesame.

**`products/{retailer}_{ingredientId}`**
```json
{
  "retailer": "migros",
  "ingredientId": "karotten",
  "label": "Karotten 1 kg",
  "packSize": 1000,
  "priceChf": 2.20,
  "priceCheckedAt": "2026-11-20",
  "isDummy": true
}
```
`retailer`: migros | coop | aldi | lidl | denner.

**`recipes/{recipeId}`**
```json
{
  "id": "ofengemuese-feta",
  "title": "Ofengemüse mit Feta",
  "servings": 2,
  "prepMinutes": 35,
  "appliances": ["oven"],
  "dietTags": ["vegetarian"],
  "kidFriendly": true,
  "mainProtein": "cheese",
  "cuisine": "mediterran",
  "ingredients": [
    { "ingredientId": "karotten", "qty": 300 },
    { "ingredientId": "feta", "qty": 150 }
  ],
  "steps": [
    { "text": "Ofen auf 200 °C vorheizen.", "minutes": 5 }
  ],
  "imagePath": "recipes/ofengemuese-feta.jpg",
  "isDummy": true
}
```
`appliances`: oven | stove | steamer | airfryer | microwave.

### Nutzerdaten

**`households/{householdId}`**
```json
{
  "memberUids": ["uid1"],
  "retailer": "migros",
  "postalCode": "8004",
  "servings": 2,
  "kidFriendly": false,
  "cookingDays": [1, 2, 4, 5],
  "shoppingDay": "auto",
  "budgetChf": 90,
  "cheapestMode": false,
  "diet": "omnivore",
  "allergens": ["peanuts"],
  "avoidIngredientIds": ["koriander"],
  "appliances": ["oven", "stove"],
  "hiddenRecipeIds": [],
  "favoriteRecipeIds": [],
  "painPoint": "too_expensive",
  "testerName": "Anna",
  "createdAt": "…"
}
```
`cookingDays`: 1 = Montag. `shoppingDay`: "auto" = Tag vor dem ersten Kochabend, sonst 1–7. `diet`: omnivore | vegetarian | vegan | pescetarian | high_protein. `testerName`: freiwilliger Vorname, damit Stephan Feedback zuordnen kann.

**`households/{id}/pantry/{ingredientId}`**
```json
{ "ingredientId": "reis", "isStapleOverride": null, "leftoverQty": 400, "updatedAt": "…" }
```
`leftoverQty` = Packungsrest aus früheren Wochen. Ein Eintrag ohne Menge bedeutet «vorhanden, Menge egal».

**`households/{id}/weeks/{weekId}`**
```json
{
  "weekId": "2026-W48",
  "status": "open",
  "shoppingDate": "2026-11-23",
  "budgetChf": 90,
  "dinners": [
    {
      "date": "2026-11-24",
      "recipeId": "ofengemuese-feta",
      "state": "planned",
      "costChf": 7.80,
      "changeReason": null,
      "rating": null
    }
  ],
  "shoppingList": [
    {
      "ingredientId": "karotten", "productLabel": "Karotten 1 kg",
      "packs": 1, "priceChf": 2.20, "category": "gemuese",
      "checked": false, "custom": false
    }
  ],
  "totalChf": 84.30,
  "residualValueChf": 6.10,
  "overBudgetChf": 0,
  "actualReceiptChf": null,
  "generatedAt": "…",
  "plannerVersion": "1.0.0"
}
```
`status`: open | locked | done. `state`: planned | cooked | eating_out | removed. `rating`: up | down | null. `actualReceiptChf`: Betrag laut Kassenbon, vom Tester eingegeben (Abschnitt 7).

### Testauswertung

**`feedback/{autoId}`**
```json
{ "householdId": "…", "uid": "…", "screen": "week", "type": "free_text", "text": "…", "answers": null, "createdAt": "…" }
```
`type`: free_text | weekly_survey.

**`events/{autoId}`**
```json
{ "householdId": "…", "uid": "…", "name": "plan_generated", "props": { "totalChf": 84.3 }, "createdAt": "…" }
```

---

## 5. Planer (Cloud Function `generateWeek`)

Reines Modul in `/functions/src/planner`, deterministisch bei gleichem Seed, ohne Firebase-Import. Die Callable Function lädt Daten, ruft den Planer auf und speichert das Ergebnis.

### Eingaben
Haushaltsprofil, Vorrat, Rezepte, Produkte des gewählten Händlers, Rezept-IDs der letzten 3 Wochen, Seed.

### Ablauf

1. **Filtern:** Rezepte entfernen, die
   - ein Allergen aus `allergens` enthalten,
   - eine Zutat aus `avoidIngredientIds` enthalten,
   - nicht zur Ernährungsform passen,
   - ein Gerät brauchen, das fehlt,
   - in `hiddenRecipeIds` stehen,
   - in den letzten 3 Wochen gekocht oder geplant wurden (wird gelockert, falls sonst weniger als 3 × Anzahl Kochabende übrig bleiben),
   - eine Zutat ohne Produkt beim gewählten Händler haben.
   Bei `kidFriendly` nur Rezepte mit `kidFriendly: true`.
2. **Kosten einer Auswahl berechnen** (`priceSelection`):
   - Bedarf pro Zutat = Σ (Rezeptmenge × servings ÷ 2) über alle gewählten Rezepte.
   - Abzüglich `leftoverQty` aus dem Vorrat. Zutaten mit `isStaple` oder abgehaktem Vorrat ohne Menge: Bedarf 0.
   - Packungen = aufrunden(Bedarf ÷ packSize). Total = Σ Packungen × Preis.
   - Restwert = Σ (Packungen × packSize − Bedarf) × Stückpreis.
   - Kosten pro Gericht nach A1.
3. **Suchen:** Zufällige Greedy-Startlösung, danach lokale Suche mit 300 Iterationen (ein Gericht gegen ein gefiltertes Rezept tauschen, Änderung übernehmen, wenn das Ziel besser wird).
   - **Normalmodus:** Ziel = Abwechslungs-Score maximieren unter der Bedingung Total ≤ Budget; Gleichstand → kleinerer Restwert.
   - **«Möglichst günstig»:** Ziel = Total minimieren; Gleichstand → höherer Abwechslungs-Score.
   - **Abwechslungs-Score:** −3 pro doppeltem `mainProtein`, −2 pro Küche über 2-mal, −1 pro Gericht über 45 min an Werktagen, +1 pro gemeinsam genutzter Nicht-Grundzutat (weniger Reste).
4. **Budget nicht erreichbar (A2):** günstigsten gefundenen Plan zurückgeben, `overBudgetChf` setzen.
5. **Ausgabe:** Dinners mit Datum, Einkaufsliste nach Kategorie sortiert, Total, Restwert.

### Weitere Funktionen

| Function | Zweck |
| --- | --- |
| `swapOptions(weekId, date)` | 6 Alternativen (A9): beste Kandidaten nach Ziel, je mit neuer Wochensumme minus alter. |
| `applyChange(weekId, date, action, recipeId?, reason?)` | Tauschen, Verschieben, «Auswärts essen». Offene Woche: Liste neu berechnen. Gesperrte Woche: Liste bleibt, Rückgabe der Reste-Warnung nach A3. |
| `markShopped(weekId)` | Status `locked`; berechnet voraussichtliche Packungsreste für Tab «Vorrat ergänzen» (A7). |
| `markCooked(weekId, date)` | Status `cooked`. |
| `rolloverWeek` (Scheduler, täglich 03:00 Europe/Zurich) | Öffnet die nächste Woche nach A4 und erzeugt den Plan. Setzt vergangene Wochen auf `done`. |

### Tests (Pflicht)
Fixtures mit 10 Zutaten, 12 Rezepten, Produkten für 2 Händler. Mindestens prüfen:
- Packungen werden nach dem Skalieren aufgerundet.
- Allergene und «isst nicht» kommen nie vor.
- Grundvorrat und abgehakter Vorrat erscheinen nicht auf der Liste.
- Total ≤ Budget, wenn eine solche Lösung existiert; sonst `overBudgetChf > 0`.
- «Möglichst günstig» ist nie teurer als der Normalmodus.
- Gleicher Seed → gleicher Plan.
- Gesperrte Woche: «Auswärts essen» ändert die Liste nicht und liefert die Reste-Warnung.

---

## 6. Screens

### Onboarding

| Nr. | Screen | Inhalt |
| --- | --- | --- |
| 1 | Willkommen | Kurzer Nutzen in einem Satz, Hinweis «Testversion», «Los geht's» |
| 2 | Vorname | Freiwillig, «Damit Stephan dein Feedback zuordnen kann» |
| 3 | Postleitzahl | 4-stellig, Validierung 1000–9699 |
| 4 | Laden | Händler aus `enabledRetailers` als Karten; bei nur einem Händler vorausgewählt mit kurzem Hinweis |
| 5 | Haushalt | Personen 1–8, Schalter «Kinderfreundlich» |
| 6 | Kochabende | Wochentage wählen, mindestens 2 |
| 7 | Vorrat | Raster mit 24 häufigen Zutaten zum Abhaken; darunter ein geschätzter Wocheneinkauf, der beim Abhaken sinkt (Wert aus einem Beispielplan) |
| 8 | Budget | A10 |
| 9 | Hauptproblem | «Zu viel Geld für Lebensmittel», «Keine Ideen», «Zu viel Verschwendung», «Zu wenig Zeit» |
| 10 | Ernährung | Allesesser, vegetarisch, vegan, pescetarisch, proteinreich |
| 11 | Geräte | Backofen, Herd, Steamer, Heissluftfritteuse, Mikrowelle |
| 12 | Allergien | Raster, mit Hinweis «Die Filter ersetzen keine Prüfung der Zutaten.» |
| 13 | Isst nicht | Raster mit häufigen Zutaten, plus Suche |
| 14 | Zusammenfassung | Gewählte Angaben, «Plan erstellen» |
| 15 | Plan entsteht | Fortschrittsanzeige mit drei Texten («Rezepte filtern», «Preise bei Migros berechnen», «Günstigste Kombination suchen»), mindestens 3 s, dann direkt in die Woche |

Jeder Schritt speichert sofort ins Haushaltsdokument, damit ein Abbruch nicht alles verliert. Fortschrittsbalken oben, Zurück-Navigation erlaubt.

### Hauptbereich

**Woche**
- Kopf: Datumsleiste Mo–So, Wochentotal, Budgetbalken, Einstellungs-Symbol (Einkaufstag, Kochabende, Budget, Laden).
- Karte «Heute»: Gericht, Zeit, Kosten, «Kochen» öffnet das Rezept.
- Liste der weiteren Abendessen mit Menü: Tauschen, Verschieben, Ändern (Gründe nach A6).
- Hinweis bei `overBudgetChf > 0` (A2).
- Snackbar «Rückgängig» nach jeder Änderung (10 s).

**Rezept**
- Bild (Platzhalter, falls keins vorhanden), Zeit, Kosten, Portionen, Zutaten, Schritte mit Zeitangaben, «Gekocht», Daumen hoch/runter.

**Einkauf**
- Tabs «Einkaufen» und «Vorrat ergänzen» (A7).
- Liste nach Kategorien, Abhaken, eigene Artikel hinzufügen, Total und Restwert, Hinweis «Preise geschätzt».
- Knopf «Eingekauft» (sperrt die Woche, A4). Danach Frage: «Was stand auf dem Kassenbon? (optional)» → `actualReceiptChf`.
- Teilen: Liste als Text über die Web-Share-Funktion bzw. «In Zwischenablage kopieren».

**Küche**
- Vorrat nach Kategorien, Suche, Abhaken, Mengen bei Resten bearbeiten.
- Karte «Gespart durch Vorrat diese Woche: CHF X».

**Profil**
- Haushaltsangaben bearbeiten, «Auf anderem Gerät nutzen» (E-Mail-Link), Favoriten, ausgeblendete Rezepte, vergangene Wochen (3), Feedback geben, Daten löschen.

---

## 7. Feedback und Nutzungszählung (Testversion)

- **Feedback-Knopf:** im Testband und im Profil. Öffnet ein Textfeld; gespeichert in `feedback` mit dem aktuellen Screen.
- **Wochenumfrage:** Wenn eine Woche auf `done` wechselt, beim nächsten Öffnen einmalig 4 Fragen:
  1. Wie viele der geplanten Abendessen hast du gekocht? (0 bis alle)
  2. Wie nah war der geschätzte Preis am Kassenbon? (viel tiefer, etwas tiefer, passt, etwas höher, viel höher)
  3. Was hat gefehlt oder gestört? (Freitext)
  4. Würdest du für die App CHF 39 pro Jahr zahlen? (ja, vielleicht, nein) + «Warum?» (Freitext)
- **Ereignisse** in `events`: `onboarding_step_viewed` (step), `onboarding_completed`, `plan_generated` (totalChf, budgetChf, overBudgetChf), `app_opened`, `dinner_swapped` (reason), `dinner_eating_out`, `dinner_cooked`, `dinner_rated`, `shopping_marked_done` (totalChf, actualReceiptChf), `list_shared`, `feedback_sent`.
- **Auswertung:** `scripts/export-test-results` schreibt eine CSV pro Haushalt: Tester-Vorname, Wochen, gekochte Abendessen, geschätztes Total vs. Kassenbon, Umfrageantworten, Freitexte.

---

## 8. Datenschutz in der Testversion

- Keine E-Mail-Adresse nötig; nur freiwilliger Vorname und PLZ.
- Kurzer Hinweistext beim Start: welche Daten gespeichert werden und dass sie nur zur Verbesserung der App dienen.
- «Daten löschen» im Profil entfernt Haushalt, Wochen, Vorrat, Feedback und Ereignisse dieses Nutzers.

---

## 9. Meilensteine

Jeder Meilenstein endet mit lauffähiger App, grünen Tests und einer kurzen Notiz in `/docs/CHANGELOG.md`. Nach jedem Meilenstein anhalten und auf Freigabe warten.

| Nr. | Inhalt | Fertig, wenn |
| --- | --- | --- |
| M1 | Repo-Gerüst, Flutter-Web-App mit leeren Tabs, Firebase-Emulatoren lokal, Datenmodell, Security Rules, Import- und Validierungsskript für CSV und JSON, **Dummy-Stammdaten** (40 Zutaten, 30 Rezepte, Produkte für Migros und Coop, alle `isDummy: true`) | Import lädt die Daten in den Emulator; Validierung meldet keine Fehler; `flutter run -d chrome` zeigt die App |
| M2 | Planer mit allen Tests aus Abschnitt 5, Callable `generateWeek` | Alle Tests grün; Aufruf im Emulator liefert einen Plan |
| M3 | Onboarding 1–15 mit Speichern pro Schritt | Im Browser durchspielbar, auch in Handy-Breite; Daten korrekt in Firestore |
| M4 | Woche und Rezept, inkl. Tauschen, Verschieben, Auswärts essen, Rückgängig | Alle Aktionen ändern Plan und Total korrekt |
| M5 | Einkauf und Küche, Sperren der Woche, Kassenbon-Frage, Reste-Warnung, Vorrat ergänzen, `rolloverWeek` | Ablauf «planen – einkaufen – kochen – Reste – nächste Woche» funktioniert im Emulator |
| M6 | Feedback, Wochenumfrage, Ereignisse, Export-Skript, Testband, Datenschutzhinweis, Daten löschen, E-Mail-Link | Export erzeugt eine korrekte CSV aus Testdaten |
| M7 | Auslieferung: Anleitung und Skripte für ein echtes Firebase-Projekt und Firebase Hosting | Stephan kann mit `firebase login` und einem dokumentierten Befehl veröffentlichen; Build mit `isDummy: true`-Daten in Produktion wird vom Validierungsskript blockiert |

Für M7 legt Claude Code kein Firebase-Projekt selbst an. Er bereitet Konfiguration und Anleitung vor; Stephan führt Login und erstes Deployment aus.

---

## 10. Inhalte, die nicht Claude Code erstellt

- **Echte Stammdaten vor dem Test:** Migros-Referenzpreise für alle Zutaten der Testrezepte und 40–50 geprüfte Rezepte. Pflege am einfachsten in einer Tabelle (Zutaten, Produkte, Rezepte, Rezeptzutaten), exportiert als CSV nach `/data` und mit dem Import-Skript geladen.
- **Rezeptbilder** (optional für den Test).

---

## 11. Später (nach einem guten Test, nicht jetzt bauen)

- Paywall und Abos über RevenueCat: Jahresabo CHF 39 mit 7 Tagen Gratistest, Monatsabo CHF 9.90; harte Paywall nach einer Plan-Vorschau.
- iOS- und Android-Builds, Push-Mitteilungen (Einkaufstag, Ende Gratistest), App-Store-Bewertung, Login mit Apple und Google.
- Haushalt teilen per Code.
- Weitere Händler, Empfehlungscodes für Creator, Analytics über Firebase Analytics.
