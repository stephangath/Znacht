import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/shell/placeholder_page.dart';
import '../../l10n/app_localizations.dart';
import 'dev_info_card.dart';

/// Entwickler-Info (Emulator, Stammdaten) nur im Debug-Build; in Tests abschaltbar.
final showDevInfoProvider = Provider<bool>((ref) => kDebugMode);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l10n.profileEmptyTitle,
      body: l10n.profileEmptyBody,
      icon: Icons.person,
      footer: ref.watch(showDevInfoProvider) ? const DevInfoCard() : null,
    );
  }
}
