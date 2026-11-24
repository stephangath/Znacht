# Znacht – Flutter-App

Web zuerst; iOS und Android folgen später aus derselben Codebasis.

Start (Emulatoren müssen laufen, siehe README im Repo-Root):

```bash
flutter run -d chrome
```

- `lib/features/…` – Bereiche der App (Woche, Einkauf, Küche, Profil, später Onboarding und Feedback)
- `lib/data/models` – Datenmodell (Gegenstück zu `functions/src/model/types.ts`)
- `lib/data/repositories` – Firestore-Zugriffe
- `l10n/app_de.arb` – alle Texte (Schweizer Rechtschreibung, «ss» statt «ß»)
