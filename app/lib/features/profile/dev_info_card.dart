import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../l10n/app_localizations.dart';

typedef DevCatalogInfo = ({int recipes, List<String> retailers});

/// Liest Anzahl Rezepte und aktive Händler aus dem Emulator.
final devCatalogInfoProvider = FutureProvider<DevCatalogInfo>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  final recipes = await repo.countRecipes();
  final config = await repo.loadConfig();
  return (recipes: recipes, retailers: [for (final r in config.enabledRetailers) r.wire]);
});

/// Nur im Debug-Build: zeigt, ob Emulator und Stammdaten erreichbar sind.
class DevInfoCard extends ConsumerWidget {
  const DevInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(devCatalogInfoProvider);
    final text = switch (info) {
      AsyncData(:final value) when value.recipes == 0 => l10n.devInfoNoData,
      AsyncData(:final value) =>
        '${l10n.devInfoEmulator}\n${l10n.devInfoCatalog(value.recipes, value.retailers.join(', '))}',
      AsyncError(:final error) => l10n.devInfoError(error.toString()),
      _ => '…',
    };
    return Card(
      child: ListTile(
        leading: const Icon(Icons.developer_mode),
        title: Text(l10n.devInfoTitle),
        subtitle: Text(text),
      ),
    );
  }
}
