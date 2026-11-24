import 'package:material_ui/material_ui.dart';

/// Eigenständige Gestaltung: dunkles Salbeigrün mit warmem Akzent.
class AppTheme {
  static const _seed = Color(0xFF3E6B57);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: _seed);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
    );
  }
}
