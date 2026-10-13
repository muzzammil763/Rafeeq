import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lastPlayedRepoProvider = Provider<LastPlayedRepo>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return LastPlayedRepo(sharedPreferences);
});

// Stream provider for real-time updates of last played position
final lastPlayedStreamProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(lastPlayedRepoProvider);
  return repo.lastPlayedStream;
});

class LastPlayedRepo {
  final SharedPreferences _sharedPreferences;
  final StreamController<int> _lastPlayedController =
      StreamController<int>.broadcast();

  LastPlayedRepo(this._sharedPreferences);

  Stream<int> get lastPlayedStream => _lastPlayedController.stream;

  Future<void> saveGlobalLastPlayedIndex(int index) async {
    await _sharedPreferences.setInt(globalLastPlayedIndexKey, index);
    _lastPlayedController.add(index);
  }

  int getGlobalLastPlayedIndex() {
    return _sharedPreferences.getInt(globalLastPlayedIndexKey) ?? -1;
  }

  void dispose() {
    _lastPlayedController.close();
  }
}

const String globalLastPlayedIndexKey = "global_last_played_index";
