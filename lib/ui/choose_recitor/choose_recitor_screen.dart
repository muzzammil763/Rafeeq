import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/reciters_list.dart';
import 'package:rafeeq/data/repo/recitors_repo.dart';
import 'package:rafeeq/l10n/app_localization_ext.dart';
import 'package:rafeeq/ui/app_home/home/settings_picker.dart';
import 'package:rafeeq/ui/choose_recitor/reciter_state_notifier.dart';
import 'package:rafeeq/ui/quran/quran_audio_controller.dart';
import 'package:rafeeq/ui/quran/quran_player_layout.dart';

class ChooseReciterScreen extends ConsumerWidget {
  const ChooseReciterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReciter = ref.watch(reciterStateNotifierProvider).reciter;
    final playerVisible = ref.watch(
      quranAudioControllerProvider.select((state) => state.isVisible),
    );
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';

    return SettingsPickerScaffold(
      title: context.loc.chooseReciter,
      itemCount: kAllRecitersList.length,
      bottomPadding: quranPlayerAwareBottomPadding(
        context,
        playerVisible: playerVisible,
      ),
      itemBuilder: (context, index, palette) {
        final reciter = kAllRecitersList[index];
        final isSelected = reciter.identifier == selectedReciter.identifier;

        return SettingsPickerTile(
          key: ValueKey('reciter_${reciter.identifier}'),
          title: isUrdu ? reciter.name : reciter.englishName,
          selected: isSelected,
          palette: palette,
          onTap: () async {
            if (isSelected) return;
            await ref.read(recitersRepoProvider).setReciter(reciter);
            await ref
                .read(quranAudioControllerProvider.notifier)
                .reloadCurrentSelection();
          },
        );
      },
    );
  }
}
