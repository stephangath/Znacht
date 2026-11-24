# Znacht

Arbeitstitel. Die App plant die Abendessen einer Woche so, dass der Einkauf unter einem selbst gesetzten Budget bleibt. Die erste Version ist eine Web-App für einen Test mit Freunden und Familie.

- Spezifikation: [`docs/SPEC.md`](docs/SPEC.md)
- Stand der Meilensteine: [`docs/CHANGELOG.md`](docs/CHANGELOG.md)
- Stammdaten (Format, Regeln): [`docs/DATA.md`](docs/DATA.md)

Bis M6 läuft alles nur lokal mit den Firebase-Emulatoren. Es gibt kein echtes Firebase-Projekt und keine Schlüssel.

## Voraussetzungen

| Werkzeug | Version | Installation (macOS) |
| --- | --- | --- |
| Flutter (mit Dart) | stable, getestet mit 3.50.1 | https://docs.flutter.dev/get-started/install |
| Node.js | 20 (siehe `.nvmrc`) | `nvm install 20 && nvm use 20` |
| Firebase CLI | ≥ 15 | `npm install -g firebase-tools` |
| Java | ≥ 21 (für den Firestore-Emulator) | `brew install openjdk@21` |
| Chrome | aktuell | – |

Ein `firebase login` ist für die Emulatoren nicht nötig. Die FlutterFire CLI braucht es erst bei der Auslieferung (M7).

## Lokal starten

Einmalig nach dem Klonen:

```bash
npm run setup
```

Dann in drei Terminals, jeweils im Repo-Root:

```bash
npm run emulators       # 1. Firebase-Emulatoren (Auth, Firestore, Functions); UI auf http://127.0.0.1:4000
```

```bash
npm run data:import     # 2. Stammdaten prüfen und in den Emulator laden (nach jedem Emulator-Start)
```

```bash
npm run app             # 3. App in Chrome starten (= cd app && flutter run -d chrome)
```

Mit `npm run emulators:keep` bleiben die Emulator-Daten zwischen zwei Starts erhalten (Ordner `emulator-data/`, nicht im Git).

Im Profil-Tab zeigt der Debug-Build eine Karte «Entwicklung». Darauf steht, ob die App mit den Emulatoren verbunden ist und wie viele Rezepte sie findet.

Um die Handy-Breite zu testen: In Chrome die DevTools öffnen (⌥⌘I), dann die Geräte-Symbolleiste (⇧⌘M).

## Tests

```bash
npm test                # Functions, Skripte, Flutter
```

```bash
npm run test:rules      # Security Rules (startet dafür einen eigenen Firestore-Emulator)
```

```bash
npm run data:validate   # nur die Stammdaten prüfen
```

## Struktur

```
/app         Flutter-App (Web zuerst)
/functions   Cloud Functions (TypeScript, Node 20); src/planner = Planungslogik ohne Firebase
/data        Stammdaten als CSV (aktuell Dummy-Daten)
/scripts     Import und Validierung der Stammdaten
/docs        Spezifikation, Datenformat, Changelog
```
