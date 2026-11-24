import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Ab dieser Breite erscheint eine Seitenleiste statt der Tabs unten (A8).
const wideLayoutBreakpoint = 800.0;

class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Rahmen mit den vier Hauptbereichen Woche, Einkauf, Küche, Profil.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      _Destination(Icons.calendar_view_week_outlined, Icons.calendar_view_week, l10n.tabWeek),
      _Destination(Icons.shopping_basket_outlined, Icons.shopping_basket, l10n.tabShopping),
      _Destination(Icons.kitchen_outlined, Icons.kitchen, l10n.tabKitchen),
      _Destination(Icons.person_outline, Icons.person, l10n.tabProfile),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > wideLayoutBreakpoint) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
            ],
          ),
        );
      },
    );
  }
}
