import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

/// Sprache der App: Hochdeutsch mit Schweizer Rechtschreibung.
const appLocale = Locale('de', 'CH');

class ZnachtApp extends StatefulWidget {
  const ZnachtApp({super.key, this.router});

  /// Für Tests überschreibbar.
  final GoRouter? router;

  @override
  State<ZnachtApp> createState() => _ZnachtAppState();
}

class _ZnachtAppState extends State<ZnachtApp> {
  late final GoRouter _router = widget.router ?? createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: appLocale,
      supportedLocales: const [appLocale],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: _router,
    );
  }
}
