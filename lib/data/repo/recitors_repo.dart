import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:rafeeq/data/reciters_list.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

final recitersRepoProvider = Provider<RecitersRepo>((ref) {
  final rxPrefs = ref.watch(rxSharedPreferencesProvider);
  return RecitersRepo(rxPrefs);
});

const kSelectedReciter = 'KEY_SELECTED_RECITER';
const kSelectedSurahReciter = 'KEY_SELECTED_SURAH_RECITER';

class RecitersRepo {
  final RxSharedPreferences _rxPrefs;

  RecitersRepo(this._rxPrefs);

  Future<void> setReciter(Reciter reciter) async {
    await _rxPrefs.setString(kSelectedReciter, reciter.identifier);
  }

  Future<void> setSurahReciter(SurahReciter surahReciter) async {
    await _rxPrefs.setString(kSelectedSurahReciter, surahReciter.identifier);
  }

  Future<Reciter> getReciter() async {
    final selectedReciterId = await _rxPrefs.getString(kSelectedReciter);
    if (selectedReciterId == null || selectedReciterId.isEmpty) {
      return kAllRecitersList.first;
    }

    return kAllRecitersList
            .where((element) => element.identifier == selectedReciterId)
            .firstOrNull ??
        kAllRecitersList.first;
  }

  Future<SurahReciter> getSurahReciter() async {
    const allSurahReciters = SurahReciter.values;
    final selectedSurahReciterId = await _rxPrefs.getString(
      kSelectedSurahReciter,
    );
    if (selectedSurahReciterId == null || selectedSurahReciterId.isEmpty) {
      return allSurahReciters.first;
    }

    return allSurahReciters
            .where((element) => element.identifier == selectedSurahReciterId)
            .firstOrNull ??
        allSurahReciters.first;
  }

  Stream<Reciter> getReciterStream() {
    return _rxPrefs.getStringStream(kSelectedReciter).map((recitorId) {
      if (recitorId == null || recitorId.isEmpty) {
        return kAllRecitersList.first;
      }

      return kAllRecitersList
              .where((element) => element.identifier == recitorId)
              .firstOrNull ??
          kAllRecitersList.first;
    });
  }

  Stream<SurahReciter> getSurahReciterStream() {
    const allSurahReciters = SurahReciter.values;
    return _rxPrefs.getStringStream(kSelectedSurahReciter).map((recitorId) {
      if (recitorId == null || recitorId.isEmpty) {
        return allSurahReciters.first;
      }

      return allSurahReciters
              .where((element) => element.identifier == recitorId)
              .firstOrNull ??
          allSurahReciters.first;
    });
  }
}
