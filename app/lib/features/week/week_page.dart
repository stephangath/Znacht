import 'package:material_ui/material_ui.dart';

import '../../core/shell/placeholder_page.dart';
import '../../l10n/app_localizations.dart';

class WeekPage extends StatelessWidget {
  const WeekPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l10n.weekEmptyTitle,
      body: l10n.weekEmptyBody,
      icon: Icons.calendar_view_week,
    );
  }
}
