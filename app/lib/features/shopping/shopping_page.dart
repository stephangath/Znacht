import 'package:material_ui/material_ui.dart';

import '../../core/shell/placeholder_page.dart';
import '../../l10n/app_localizations.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l10n.shoppingEmptyTitle,
      body: l10n.shoppingEmptyBody,
      icon: Icons.shopping_basket,
    );
  }
}
