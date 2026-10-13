import 'package:flutter/material.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/localized_font.dart';

class VersionScreen extends StatelessWidget {
  const VersionScreen({super.key});

  static const _version = '1.2.21+50';

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final releases = [
      _VersionRelease(
        version: _version,
        introduction: context.loc.versionDetailsIntro,
        sections: [
          (
            context.loc.versionDetailsFeatures,
            context.loc.versionDetailsFeaturesBody,
          ),
          (
            context.loc.versionDetailsDesign,
            context.loc.versionDetailsDesignBody,
          ),
          (
            context.loc.versionDetailsEnhancements,
            context.loc.versionDetailsEnhancementsBody,
          ),
          (
            context.loc.versionDetailsBugFixes,
            context.loc.versionDetailsBugFixesBody,
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: context.loc.version,
        palette: palette,
        showBackButton: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
            children: [
              for (var index = 0; index < releases.length; index++) ...[
                _VersionReleaseContent(
                  release: releases[index],
                  palette: palette,
                ),
                if (index != releases.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Divider(
                      color: palette.subtitle.withValues(alpha: 0.14),
                      height: 1,
                      thickness: 1,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionRelease {
  const _VersionRelease({
    required this.version,
    required this.introduction,
    required this.sections,
  });

  final String version;
  final String introduction;
  final List<(String, String)> sections;
}

class _VersionReleaseContent extends StatelessWidget {
  const _VersionReleaseContent({required this.release, required this.palette});

  final _VersionRelease release;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          release.version,
          style: TextStyle(
            color: palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          release.introduction,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: localizedFontFamily(context),
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        for (var index = 0; index < release.sections.length; index++) ...[
          _VersionSection(
            title: release.sections[index].$1,
            body: release.sections[index].$2,
            palette: palette,
          ),
          if (index != release.sections.length - 1) const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _VersionSection extends StatelessWidget {
  const _VersionSection({
    required this.title,
    required this.body,
    required this.palette,
  });

  final String title;
  final String body;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: 17,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: localizedFontFamily(context),
            fontSize: 15,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}
