import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';

class SettingsPickerScaffold extends ConsumerWidget {
  const SettingsPickerScaffold({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.bottomPadding,
  });

  final String title;
  final int itemCount;
  final double? bottomPadding;
  final Widget Function(
    BuildContext context,
    int index,
    SettingsPalette palette,
  )
  itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = SettingsPalette.of(context);
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final effectiveBottomPadding =
        bottomPadding ??
        quranPlayerAwareBottomPadding(context, playerVisible: playerVisible);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: SettingsAppBar(title: title, palette: palette),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  effectiveBottomPadding,
                ),
                itemCount: itemCount,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    itemBuilder(context, index, palette),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SettingsAppBar extends RafeeqAppBar {
  const SettingsAppBar({
    super.key,
    required super.title,
    required super.palette,
    super.onBack,
    super.actions,
  }) : super(showBackButton: true);
}

class HomeLocationAction extends StatelessWidget {
  const HomeLocationAction({
    super.key,
    required this.location,
    required this.palette,
    required this.onTap,
  });

  final String location;
  final SettingsPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.card.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.location, color: palette.title, size: 16),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 145),
                child: MediaQuery.withNoTextScaling(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.title,
                      fontFamily: 'GoogleSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.palette,
    this.leading,
    this.subtitle,
    this.supporting,
    this.trailing,
    this.onTap,
    this.switchValue,
    this.onSwitchChanged,
    this.foregroundColor,
    this.disableSubtitleTextScaling = false,
    this.badge,
  }) : assert(
         (switchValue == null) == (onSwitchChanged == null),
         'Switch value and callback must be supplied together.',
       );

  final IconData icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? supporting;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final Color? foregroundColor;
  final bool disableSubtitleTextScaling;
  final String? badge;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = onSwitchChanged == null
        ? onTap
        : () => onSwitchChanged!(!switchValue!);
    final titleColor = palette.title;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: effectiveOnTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 14, 12, 14),
              child: Row(
                children: [
                  leading ??
                      SizedBox(
                        width: 24,
                        child: Icon(
                          icon,
                          color: foregroundColor ?? palette.accent,
                          size: 22,
                        ),
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontFamily:
                                Localizations.localeOf(context).languageCode ==
                                    'ur'
                                ? 'Jameel Noori Nastaleeq'
                                : 'GoogleSans',
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          _OptionalNoTextScaling(
                            disabled: !disableSubtitleTextScaling,
                            child: Text(
                              subtitle!,
                              style: TextStyle(
                                color: palette.subtitle,
                                fontFamily:
                                    Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ur'
                                    ? 'Jameel Noori Nastaleeq'
                                    : 'GoogleSans',
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                        if (supporting != null) ...[
                          const SizedBox(height: 8),
                          supporting!,
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                  if (onSwitchChanged != null) ...[
                    const SizedBox(width: 12),
                    CupertinoSwitch(
                      value: switchValue!,
                      activeTrackColor: palette.accent,
                      onChanged: onSwitchChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (badge case final badge?)
          Positioned(
            top: -4,
            right: -4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                  maxHeight: 20,
                  maxWidth: 32,
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'GoogleSans',
                      fontSize: 10,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionalNoTextScaling extends StatelessWidget {
  const _OptionalNoTextScaling({required this.disabled, required this.child});

  final bool disabled;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      disabled ? child : MediaQuery.withNoTextScaling(child: child);
}

class SettingsPickerTile extends StatelessWidget {
  const SettingsPickerTile({
    super.key,
    required this.title,
    required this.selected,
    required this.palette,
    required this.onTap,
    this.subtitle,
    this.supporting,
    this.subtitleFontFamily,
  });

  final String title;
  final String? subtitle;
  final Widget? supporting;
  final String? subtitleFontFamily;
  final bool selected;
  final SettingsPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.selectedCard : palette.card,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? palette.selectedTitle
                              : palette.title,
                          fontFamily:
                              Localizations.localeOf(context).languageCode ==
                                  'ur'
                              ? 'Jameel Noori Nastaleeq'
                              : 'GoogleSans',
                          fontSize: 15,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? palette.selectedSubtitle
                                : palette.subtitle,
                            fontFamily:
                                subtitleFontFamily ??
                                (Localizations.localeOf(context).languageCode ==
                                        'ur'
                                    ? 'Jameel Noori Nastaleeq'
                                    : 'GoogleSans'),
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if (supporting != null) ...[
                        const SizedBox(height: 4),
                        supporting!,
                      ],
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: palette.selectedTitle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.check_mark,
                      size: 14,
                      color: palette.selectedCard,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
