import 'package:go_router/go_router.dart';

import 'core/shell/app_shell.dart';
import 'features/pantry/kitchen_page.dart';
import 'features/profile/profile_page.dart';
import 'features/shopping/shopping_page.dart';
import 'features/week/week_page.dart';

/// Pfade der Hauptbereiche. URL-basiert, damit Neuladen im Browser die Seite behält.
abstract final class AppRoutes {
  static const week = '/woche';
  static const shopping = '/einkauf';
  static const kitchen = '/kueche';
  static const profile = '/profil';
}

GoRouter createRouter({String initialLocation = AppRoutes.week}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(
            currentIndex: shell.currentIndex,
            onDestinationSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            child: shell,
          ),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: AppRoutes.week, builder: (_, _) => const WeekPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: AppRoutes.shopping, builder: (_, _) => const ShoppingPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: AppRoutes.kitchen, builder: (_, _) => const KitchenPage()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: AppRoutes.profile, builder: (_, _) => const ProfilePage()),
            ]),
          ],
        ),
      ],
    );
