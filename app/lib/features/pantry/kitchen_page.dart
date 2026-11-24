import 'package:material_ui/material_ui.dart';

import '../../core/shell/placeholder_page.dart';
import '../../l10n/app_localizations.dart';

/// Tab «Küche»: Vorrat (ab M5).
class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l10n.kitchenEmptyTitle,
      body: l10n.kitchenEmptyBody,
      icon: Icons.kitchen,
    );
  }
}
