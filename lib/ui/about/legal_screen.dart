import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/utils/localized_font.dart';

enum LegalDocument { privacy, terms }

/// Reads the same bundled policy content used by the website, even offline.
class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  late Future<Map<String, dynamic>> _content = _load();

  Future<Map<String, dynamic>> _load() async =>
      jsonDecode(await rootBundle.loadString('assets/legal.json'))
          as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final title = widget.document == LegalDocument.privacy
        ? context.loc.privacyPolicy
        : context.loc.termsAndConditions;
    final font = localizedFontFamily(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: title,
        palette: palette,
        showBackButton: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _content,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return TextButton(
                  onPressed: () => setState(() => _content = _load()),
                  child: Text(context.loc.legalRetry),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final language = Localizations.localeOf(context).languageCode;
              final versions =
                  snapshot.data![widget.document.name] as Map<String, dynamic>;
              final policy =
                  (versions[language] ?? versions['en'])
                      as Map<String, dynamic>;
              final sections = policy['sections'] as List<dynamic>;
              return SelectionArea(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.loc.appTitle,
                                style: TextStyle(
                                  fontFamily: font,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: palette.title,
                                ),
                              ),
                              Text(
                                context.loc.aboutTagline,
                                style: TextStyle(
                                  fontFamily: font,
                                  fontSize: 15,
                                  color: palette.subtitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      policy['updated'] as String,
                      style: TextStyle(
                        fontFamily: font,
                        fontSize: 13,
                        color: palette.subtitle,
                      ),
                    ),
                    for (final section in sections) ...[
                      const SizedBox(height: 28),
                      Text(
                        section['title'] as String,
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 17,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          color: palette.title,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section['body'] as String,
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: 15,
                          height: 1.75,
                          color: palette.subtitle,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: palette.selectedCard.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        'satechdev18@gmail.com',
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 15,
                          color: palette.title,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
