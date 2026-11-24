import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/firebase/firebase_setup.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'de_CH';
  await initializeDateFormatting('de_CH');

  try {
    await initFirebase();
  } catch (e) {
    runApp(_StartupErrorApp(error: e));
    return;
  }

  runApp(const ProviderScope(child: ZnachtApp()));
}

/// Fehleranzeige, falls die Emulatoren nicht laufen (noch ohne Übersetzungen,
/// weil die Lokalisierung erst in der App geladen wird).
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Die App konnte nicht starten.'),
                const SizedBox(height: 8),
                const Text('Laufen die Firebase-Emulatoren? Im Projektordner: npm run emulators'),
                const SizedBox(height: 16),
                Text('$error', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
