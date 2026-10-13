import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';

const _themeModes = <ThemeMode>[
  ThemeMode.light,
  ThemeMode.system,
  ThemeMode.dark,
];

String themeModeLabel(BuildContext context, ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => context.loc.themeModeLight,
    ThemeMode.system => context.loc.themeModeSystem,
    ThemeMode.dark => context.loc.themeModeDark,
  };
}

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(appSettingsNotifierProvider).themeMode;

    return SettingsPickerScaffold(
      title: context.loc.theme,
      itemCount: _themeModes.length,
      itemBuilder: (context, index, palette) {
        final mode = _themeModes[index];
        return ThemePickerTile(
          mode: mode,
          title: themeModeLabel(context, mode),
          selected: selectedMode == mode,
          palette: palette,
          onTap: () {
            ref.read(appSettingsNotifierProvider.notifier).setThemeMode(mode);
            ref
                .read(analyticsServiceProvider)
                .logSettingsThemeChanged(mode.name);
          },
        );
      },
    );
  }
}

class ThemePickerTile extends StatelessWidget {
  const ThemePickerTile({
    super.key,
    required this.mode,
    required this.title,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final ThemeMode mode;
  final String title;
  final bool selected;
  final SettingsPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SettingsPickerTile(
      title: title,
      selected: selected,
      palette: palette,
      onTap: onTap,
    );
  }
}

class ThemeModePreview extends StatelessWidget {
  const ThemeModePreview({super.key, required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: Container(
        width: 132,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: SettingsPalette.of(context).divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: switch (mode) {
          ThemeMode.light => const _MiniThemeLayout(light: true),
          ThemeMode.dark => const _MiniThemeLayout(light: false),
          ThemeMode.system => const Stack(
            fit: StackFit.expand,
            children: [
              ClipRect(
                clipper: _HalfPreviewClipper(leftHalf: true),
                child: _MiniThemeLayout(light: true),
              ),
              ClipRect(
                clipper: _HalfPreviewClipper(leftHalf: false),
                child: _MiniThemeLayout(light: false),
              ),
            ],
          ),
        },
      ),
    );
  }
}

class _HalfPreviewClipper extends CustomClipper<Rect> {
  const _HalfPreviewClipper({required this.leftHalf});

  final bool leftHalf;

  @override
  Rect getClip(Size size) {
    final halfWidth = size.width / 2;
    return Rect.fromLTWH(leftHalf ? 0 : halfWidth, 0, halfWidth, size.height);
  }

  @override
  bool shouldReclip(_HalfPreviewClipper oldClipper) {
    return leftHalf != oldClipper.leftHalf;
  }
}

class _MiniThemeLayout extends StatelessWidget {
  const _MiniThemeLayout({required this.light});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final palette = light ? SettingsPalette.light : SettingsPalette.dark;

    return ColoredBox(
      color: palette.background,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Container(
              width: 39,
              decoration: BoxDecoration(
                color: palette.selectedCard,
                borderRadius: BorderRadius.circular(3),
              ),
              padding: const EdgeInsets.all(4),
              alignment: Alignment.bottomLeft,
              child: Container(width: 19, height: 3, color: palette.accent),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: palette.card,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Expanded(
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: index == 2 ? 0 : 3,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: palette.card,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Theme picker cards', group: 'Settings', size: Size(390, 330))
Widget themePickerCardsPreview() {
  return MaterialApp(
    theme: ThemeData(useMaterial3: true, fontFamily: 'GoogleSans'),
    home: Builder(
      builder: (context) {
        final palette = SettingsPalette.of(context);
        return Scaffold(
          backgroundColor: palette.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final mode in _themeModes) ...[
                    ThemePickerTile(
                      mode: mode,
                      title: switch (mode) {
                        ThemeMode.light => 'Light',
                        ThemeMode.system => 'System',
                        ThemeMode.dark => 'Dark',
                      },
                      selected: mode == ThemeMode.system,
                      palette: palette,
                      onTap: () {},
                    ),
                    if (mode != _themeModes.last) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
