import 'package:material_ui/material_ui.dart';

/// Leerer Bereich, bis der zugehörige Meilenstein gebaut ist.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    this.footer,
  });

  final String title;
  final String body;
  final IconData icon;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Icon(icon, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(body, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
              if (footer != null) ...[const SizedBox(height: 32), footer!],
            ],
          ),
        ),
      ),
    );
  }
}
