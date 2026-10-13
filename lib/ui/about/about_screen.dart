import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_palette.dart';
import 'package:rafeeq/ui/widgets/rafeeq_app_bar.dart';
import 'package:rafeeq/ui/widgets/rafeeq_toast.dart';
import 'package:rafeeq/utils/localized_font.dart';
import 'package:url_launcher/url_launcher.dart';

final _rafeeqWhatsAppUpdatesUri = Uri.parse(
  'https://whatsapp.com/channel/0029Vb8mQB88KMqdnHbTIo1L',
);
final _muzamilPortfolioUri = Uri.parse('https://muzamil.web.app/');

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final TapGestureRecognizer _portfolioRecognizer;

  @override
  void initState() {
    super.initState();
    _portfolioRecognizer = TapGestureRecognizer()..onTap = _openPortfolio;
  }

  @override
  void dispose() {
    _portfolioRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openPortfolio() async {
    var opened = false;
    try {
      opened = await launchUrl(
        _muzamilPortfolioUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      showRafeeqToast(
        context,
        context.loc.aboutPortfolioOpenError,
        type: RafeeqToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = SettingsPalette.of(context);
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    final sections = [
      (context.loc.aboutBeginningTitle, context.loc.aboutBeginningBody),
      (context.loc.aboutTogetherTitle, context.loc.aboutTogetherBody),
      (context.loc.aboutDesignTitle, context.loc.aboutDesignBody),
      (context.loc.aboutUmmahTitle, context.loc.aboutUmmahBody),
      (context.loc.aboutFreeTitle, context.loc.aboutFreeBody),
      (context.loc.aboutCommunityTitle, context.loc.aboutCommunityBody),
    ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: RafeeqAppBar(
        title: context.loc.about,
        palette: palette,
        showBackButton: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
            children: [
              _AppIdentity(palette: palette),
              const SizedBox(height: 24),
              for (var index = 0; index < sections.length; index++) ...[
                _AboutSection(
                  title: sections[index].$1,
                  body: sections[index].$2,
                  emphasizedPhrases: index == 0
                      ? isUrdu
                            ? const ['مزمل غفور']
                            : const ['Muzamil Ghafoor']
                      : const [],
                  linkedPhrase: index == 0
                      ? isUrdu
                            ? 'مزمل غفور'
                            : 'Muzamil Ghafoor'
                      : null,
                  linkRecognizer: index == 0 ? _portfolioRecognizer : null,
                  palette: palette,
                ),
                if (index != sections.length - 1) const SizedBox(height: 24),
              ],
              const SizedBox(height: 24),
              _ClosingStatement(palette: palette),
              const SizedBox(height: 24),
              _WhatsAppSection(palette: palette),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhatsAppSection extends StatelessWidget {
  const _WhatsAppSection({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.loc.aboutWhatsAppTitle,
          style: TextStyle(
            color: palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: 18,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.loc.aboutWhatsAppIntroduction,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: localizedFontFamily(context),
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        _WhatsAppChannelSection(
          title: context.loc.aboutWhatsAppUpdatesTitle,
          description: context.loc.aboutWhatsAppUpdatesBody,
          buttonLabel: context.loc.aboutWhatsAppUpdatesButton,
          palette: palette,
          onPressed: () => _openWhatsApp(context, _rafeeqWhatsAppUpdatesUri),
        ),
      ],
    );
  }

  Future<void> _openWhatsApp(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      showRafeeqToast(
        context,
        context.loc.aboutWhatsAppOpenError,
        type: RafeeqToastType.error,
      );
    }
  }
}

class _WhatsAppChannelSection extends StatelessWidget {
  const _WhatsAppChannelSection({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.palette,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final SettingsPalette palette;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          description,
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: localizedFontFamily(context),
            fontSize: 15,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          key: ValueKey('about-whatsapp-$buttonLabel'),
          onPressed: onPressed,
          icon: SvgPicture.asset(
            'assets/whatsapp.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              palette.checkForeground,
              BlendMode.srcIn,
            ),
          ),
          label: Text(buttonLabel),
          style: FilledButton.styleFrom(
            backgroundColor: palette.accent,
            foregroundColor: palette.checkForeground,
            padding: const EdgeInsets.symmetric(vertical: 13),
            textStyle: TextStyle(
              fontFamily: localizedFontFamily(context),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppIdentity extends StatelessWidget {
  const _AppIdentity({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/logo.png',
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.loc.appTitle,
                style: TextStyle(
                  color: palette.title,
                  fontFamily: localizedFontFamily(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                context.loc.aboutTagline,
                style: TextStyle(
                  color: palette.subtitle,
                  fontFamily: localizedFontFamily(context),
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.title,
    required this.body,
    required this.emphasizedPhrases,
    required this.linkedPhrase,
    required this.linkRecognizer,
    required this.palette,
  });

  final String title;
  final String body;
  final List<String> emphasizedPhrases;
  final String? linkedPhrase;
  final GestureRecognizer? linkRecognizer;
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
        Text.rich(
          TextSpan(children: _buildEmphasizedSpans(body, emphasizedPhrases)),
          style: TextStyle(
            color: palette.subtitle,
            fontFamily: localizedFontFamily(context),
            fontSize: 15,
            height: 1.65,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  List<InlineSpan> _buildEmphasizedSpans(String text, List<String> phrases) {
    if (phrases.isEmpty) return [TextSpan(text: text)];

    final spans = <InlineSpan>[];
    var remaining = text;
    while (remaining.isNotEmpty) {
      String? nextPhrase;
      var nextIndex = remaining.length;
      for (final phrase in phrases) {
        final index = remaining.indexOf(phrase);
        if (index >= 0 && index < nextIndex) {
          nextIndex = index;
          nextPhrase = phrase;
        }
      }
      if (nextPhrase == null) {
        spans.add(TextSpan(text: remaining));
        break;
      }
      if (nextIndex > 0) {
        spans.add(TextSpan(text: remaining.substring(0, nextIndex)));
      }
      spans.add(
        TextSpan(
          text: nextPhrase,
          style: const TextStyle(fontWeight: FontWeight.w700),
          recognizer: nextPhrase == linkedPhrase ? linkRecognizer : null,
        ),
      );
      remaining = remaining.substring(nextIndex + nextPhrase.length);
    }
    return spans;
  }
}

class _ClosingStatement extends StatelessWidget {
  const _ClosingStatement({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.selectedCard.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          context.loc.aboutClosingStatement,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: palette.title,
            fontFamily: localizedFontFamily(context),
            fontSize: 16,
            height: 1.55,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
