import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:rafeeq/core/app_settings_notifier.dart';
import 'package:rafeeq/data/services/analytics_service.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';

final selectedLanguageIdProvider = StateProvider<String?>((ref) => null);

const languageOptions = <LanguageOption>[
  LanguageOption(id: 'en', label: 'English', effectiveLanguage: AppLanguage.en),
  LanguageOption(id: 'ur', label: 'Urdu', effectiveLanguage: AppLanguage.ur),
  /* Temporarily hidden until these locales are fully supported.
  LanguageOption(
    id: 'bn',
    label: 'Bangla (বাংলা)',
    effectiveLanguage: AppLanguage.en,
  ),
  LanguageOption(
    id: 'ar',
    label: 'Arabic (العربية)',
    effectiveLanguage: AppLanguage.en,
  ),
  LanguageOption(
    id: 'id',
    label: 'Indonesian (Bahasa Indonesia)',
    effectiveLanguage: AppLanguage.en,
  ),
  LanguageOption(
    id: 'de',
    label: 'German (Deutsch)',
    effectiveLanguage: AppLanguage.en,
  ),
  LanguageOption(
    id: 'fr',
    label: 'French (Français)',
    effectiveLanguage: AppLanguage.en,
  ),
  LanguageOption(
    id: 'ru',
    label: 'Russian (Русский)',
    effectiveLanguage: AppLanguage.en,
  ),
  LanguageOption(
    id: 'tr',
    label: 'Turkish (Türkçe)',
    effectiveLanguage: AppLanguage.en,
  ),
  LanguageOption(
    id: 'fa',
    label: 'Persian (فارسی)',
    effectiveLanguage: AppLanguage.en,
  ),
  */
];

String? languageLabelFor(BuildContext context, String? id) {
  for (final option in languageOptions) {
    if (option.id == id) return option.localizedLabel(context);
  }
  return null;
}

class LanguageOption {
  const LanguageOption({
    required this.id,
    required this.label,
    required this.effectiveLanguage,
  });

  final String id;
  final String label;
  final AppLanguage effectiveLanguage;

  String localizedLabel(BuildContext context) => switch (id) {
    'en' => context.loc.languageEnglish,
    'ur' => context.loc.languageUrdu,
    _ => label,
  };
}

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLanguage = ref.watch(appSettingsNotifierProvider).language;
    final selectedLanguageId = ref.watch(selectedLanguageIdProvider);
    final selectedId =
        selectedLanguageId ??
        switch (appLanguage) {
          AppLanguage.en => 'en',
          AppLanguage.ur => 'ur',
        };

    return SettingsPickerScaffold(
      title: context.loc.language,
      itemCount: languageOptions.length,
      itemBuilder: (context, index, palette) {
        final option = languageOptions[index];
        return SettingsPickerTile(
          title: option.localizedLabel(context),
          selected: option.id == selectedId,
          palette: palette,
          onTap: () {
            ref.read(selectedLanguageIdProvider.notifier).state = option.id;
            ref
                .read(analyticsServiceProvider)
                .logSettingsLanguageChanged(
                  option.effectiveLanguage.languageCode,
                );
            ref
                .read(appSettingsNotifierProvider.notifier)
                .setLanguage(option.effectiveLanguage);
          },
        );
      },
    );
  }
}
