import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rafeeq/core/navigation/app_routes.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/center_loading_view.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/localized_font.dart';

/// Every package bundled with the app, as registered in [LicenseRegistry].
Future<Map<String, List<LicenseEntry>>> loadPackageLicenses() async {
  final byPackage = <String, List<LicenseEntry>>{};
  await for (final entry in LicenseRegistry.licenses) {
    for (final package in entry.packages) {
      byPackage.putIfAbsent(package, () => []).add(entry);
    }
  }
  final names = byPackage.keys.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return {for (final name in names) name: byPackage[name]!};
}

class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key});

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  late final Future<Map<String, List<LicenseEntry>>> _licenses =
      loadPackageLicenses();

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: context.loc.licenses,
        palette: palette,
        showBackButton: true,
      ),
      body: FutureBuilder(
        future: _licenses,
        builder: (context, snapshot) {
          final licenses = snapshot.data;
          if (licenses == null) return const CenterLoadingView();
          final packages = licenses.keys.toList();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView.separated(
                key: const Key('licenses-list'),
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                itemCount: packages.length + 1,
                separatorBuilder: (context, index) =>
                    SizedBox(height: index == 0 ? 16 : 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Text(
                      context.loc.licensesIntro,
                      style: TextStyle(
                        color: palette.subtitle,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 15,
                        height: 1.55,
                      ),
                    );
                  }
                  final package = packages[index - 1];
                  final entries = licenses[package]!;
                  return _PackageTile(
                    package: package,
                    count: entries.length,
                    palette: palette,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(
                          name: AppRoutes.licenseDetail,
                        ),
                        builder: (_) => LicenseDetailScreen(
                          package: package,
                          entries: entries,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.package,
    required this.count,
    required this.palette,
    required this.onTap,
  });

  final String package;
  final int count;
  final SettingsPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('license-$package'),
      color: palette.card,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // Package names are identifiers, so keep them Latin.
                      style: TextStyle(
                        color: palette.title,
                        fontFamily: 'GoogleSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.loc.licensesCount(count),
                      style: TextStyle(
                        color: palette.subtitle,
                        fontFamily: localizedFontFamily(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: palette.subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The full license text for one package.
class LicenseDetailScreen extends StatelessWidget {
  const LicenseDetailScreen({
    super.key,
    required this.package,
    required this.entries,
  });

  final String package;
  final List<LicenseEntry> entries;

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final paragraphs = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      if (i > 0) {
        paragraphs.add(Divider(height: 32, color: palette.divider));
      }
      for (final paragraph in entries[i].paragraphs) {
        final centered = paragraph.indent == LicenseParagraph.centeredIndent;
        paragraphs.add(
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: centered ? 0 : 16.0 * paragraph.indent,
              bottom: 10,
            ),
            child: Text(
              paragraph.text,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: palette.subtitle,
                fontFamily: 'GoogleSans',
                fontSize: 13,
                height: 1.5,
                fontWeight: centered ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: package,
        palette: palette,
        showBackButton: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            key: const Key('license-detail'),
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: paragraphs,
          ),
        ),
      ),
    );
  }
}
