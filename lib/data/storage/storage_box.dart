import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// a simple wrapper around shared preferences to make it easier to use
/// and to make it more type safe
/// usage:
// ignore: unintended_html_in_doc_comment
/// final myBox = StorageBox<SomeClass>('my_key', (value) => jsonEncode(value), (value) => jsonDecode(value));
/// myBox.set(SomeClass());
/// final value = myBox.get();
class StorageBox<T> {
  final String key;
  final String Function(T) encoder;
  final T Function(String) decoder;
  final T? defaultValue;
  final SharedPreferences _prefs;

  StorageBox(
    this.key, {
    required this.encoder,
    required this.decoder,
    this.defaultValue,
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  Future<void> set(T value) async {
    final encoded = encoder(value);
    await _prefs.setString(key, encoded);
  }

  T? getOrNull() {
    try {
      final encoded = _prefs.getString(key);
      if (encoded == null || encoded.isEmpty) return null;
      return decoder(encoded);
    } catch (e) {
      return null;
    }
  }

  T get() {
    return getOrNull() ?? defaultValue!;
  }
}

/// Provider to get a StorageBox factory
final storageBoxProvider = Provider<StorageBoxFactory>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageBoxFactory(prefs);
});

/// Factory for creating StorageBox instances with the correct SharedPreferences
class StorageBoxFactory {
  final SharedPreferences _prefs;

  StorageBoxFactory(this._prefs);

  StorageBox<T> create<T>(
    String key, {
    required String Function(T) encoder,
    required T Function(String) decoder,
    T? defaultValue,
  }) {
    return StorageBox<T>(
      key,
      encoder: encoder,
      decoder: decoder,
      defaultValue: defaultValue,
      prefs: _prefs,
    );
  }
}
