import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:znacht/app.dart';
import 'package:znacht/features/profile/profile_page.dart';
import 'package:znacht/router.dart';

Future<void> pumpApp(WidgetTester tester, Size size, {String location = AppRoutes.week}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [showDevInfoProvider.overrideWithValue(false)],
      child: ZnachtApp(router: createRouter(initialLocation: location)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Handy-Breite: vier Tabs unten', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    for (final label in ['Woche', 'Einkauf', 'Küche', 'Profil']) {
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
          findsOneWidget);
    }
    expect(find.text('Dein Wochenplan'), findsOneWidget);
  });

  testWidgets('Breiter Bildschirm (> 800 px): Seitenleiste', (tester) async {
    await pumpApp(tester, const Size(1200, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Tabs wechseln und URL folgt', (tester) async {
    final router = createRouter();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [showDevInfoProvider.overrideWithValue(false)],
      child: ZnachtApp(router: router),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Einkauf'));
    await tester.pumpAndSettle();
    expect(find.text('Einkaufsliste'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.uri.path, AppRoutes.shopping);

    await tester.tap(find.text('Küche'));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, AppRoutes.kitchen);
  });

  testWidgets('Direkter Aufruf einer URL öffnet den richtigen Tab', (tester) async {
    await pumpApp(tester, const Size(390, 844), location: AppRoutes.profile);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 3);
  });

  test('Keine «ß» in den App-Texten', () {
    // Schweizer Rechtschreibung: immer «ss».
    // Tests laufen im App-Verzeichnis.
    final arb = File('l10n/app_de.arb').readAsStringSync();
    expect(arb.contains('ß'), isFalse);
  });
}
