# Changelog

## M1 – Gerüst, Datenmodell, Dummy-Stammdaten (24.11.2026)

**Gebaut**
- Repo-Struktur nach SPEC Abschnitt 3. Im Root stehen Befehle für Emulatoren, Daten und Tests (`package.json`).
- Firebase nur lokal: Emulatoren für Auth, Firestore und Functions, Projekt `demo-znacht`. Ein `demo-`-Projekt kann keine echten Ressourcen erreichen. Es gibt keine Schlüssel und kein echtes Projekt.
- Security Rules nach SPEC Abschnitt 4:
  - Stammdaten und `config` sind nur lesbar.
  - Ein Haushalt ist nur für seine Mitglieder zugänglich. Die Haushalts-ID ist die UID; `memberUids` ist nicht änderbar.
  - `feedback` und `events` sind nur schreibbar, und nur mit eigenen Einträgen.
  - 13 Tests laufen gegen den Emulator.
- Datenmodell als TypeScript-Typen (`functions/src/model/types.ts`) und als Dart-Modelle (`app/lib/data/models`). Wochen-ID im Format `2026-W48` nach ISO 8601.
- Dummy-Stammdaten in `/data` als CSV: 40 Zutaten, 30 Rezepte, Produkte für Migros und Coop. Alles ist `isDummy: true` und hat runde Fantasiepreise. Coop kostet überall CHF 0.50 mehr als Migros.
- Validierungsskript und Import für CSV oder JSON, mit 20 Tests. Der Import validiert zuerst und schreibt nur in `demo-`-Projekte.
- Flutter-Web-App:
  - vier leere Tabs (Woche, Einkauf, Küche, Profil) mit eigener URL
  - Seitenleiste ab 800 px Breite
  - Texte in ARB (`de_CH`), Beträge als `CHF 12.50`
  - anonyme Anmeldung beim Start
  - 18 Tests
- Kern ohne Web-only-Pakete. Plattformordner gibt es nur für Web; iOS und Android lassen sich später mit `flutter create --platforms ios,android .` ergänzen.

**Festlegungen aus der Rückfrage vor M1** (bestätigt)
- `firebase_options` von Hand mit `demo-znacht`, ohne FlutterFire (folgt in M7).
- CSV ist die führende Quelle. Es gibt eine fünfte Tabelle `recipe_steps.csv`. JSON im Firestore-Format geht alternativ.
- Ernährungs-Tags von Rezepten müssen zu den Zutaten passen. Die Validierung prüft das, Regeln in `docs/DATA.md`. Allergene werden aus den Zutaten abgeleitet.
- `householdId` = UID des anonymen Kontos.
- Kein Firebase Storage; Rezeptbilder sind vorerst Platzhalter.
- `priceChf` in der Einkaufsliste ist der Packungspreis.
- `servings` im Haushalt = Personenzahl.

**Eigene Festlegungen in M1**
- Kategorien der Einkaufsliste: `gemuese`, `milchprodukte`, `eier_tofu`, `fleisch`, `fisch`, `teigwaren_reis`, `konserven`, `backen_gewuerze`, `snacks_nuesse`, `sonstiges`.
- Feste Listen für `mainProtein` und `cuisine` (siehe `docs/DATA.md`).
- URLs mit `#` (z. B. `/#/woche`). Neuladen behält die Seite, und Hosting braucht keine Weiterleitungsregeln.

**Offen**
- Siehe Rückfragen B im Gespräch vor M1: erste Woche nach dem Onboarding, Sperre am Einkaufstag 00:00, Score-Details. Zu klären vor M2.
- Die Rules erlauben im Haushalt nur die Felder aus der SPEC. Falls das Onboarding in M3 einen Fortschritt speichern muss (z. B. `onboardingStep`), braucht es ein zusätzliches Feld.
