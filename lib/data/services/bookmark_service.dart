import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:rafeeq/data/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return BookmarkService(prefs, ref);
});

// StateProvider to track bookmark changes and trigger rebuilds
final bookmarksStateProvider = StateProvider<int>((ref) => 0);

class BookmarkService {
  static const String _bookmarksKey = 'ayah_bookmarks';
  final SharedPreferences _prefs;
  final Ref _ref;

  // Cached bookmark set for O(1) lookups
  Set<String>? _cachedBookmarks;

  BookmarkService(this._prefs, this._ref);

  /// Get all bookmarks as a list of strings in format "surahNumber:ayahNumber"
  List<String> getBookmarks() {
    final bookmarks = _prefs.getStringList(_bookmarksKey) ?? [];
    _cachedBookmarks = Set<String>.from(bookmarks);
    return bookmarks;
  }

  /// Get cached bookmark set (loads from SharedPreferences if not cached)
  Set<String> _getBookmarkSet() {
    _cachedBookmarks ??= Set<String>.from(
      _prefs.getStringList(_bookmarksKey) ?? [],
    );
    return _cachedBookmarks!;
  }

  /// Add a bookmark
  Future<bool> addBookmark(int surahNumber, int ayahNumber) async {
    final bookmarkSet = _getBookmarkSet();
    final bookmarkKey = '$surahNumber:$ayahNumber';

    if (!bookmarkSet.contains(bookmarkKey)) {
      bookmarkSet.add(bookmarkKey);
      final result = await _prefs.setStringList(
        _bookmarksKey,
        bookmarkSet.toList(),
      );
      if (result) {
        _notifyChange();
      }
      return result;
    }
    return true;
  }

  /// Remove a bookmark
  Future<bool> removeBookmark(int surahNumber, int ayahNumber) async {
    final bookmarkSet = _getBookmarkSet();
    final bookmarkKey = '$surahNumber:$ayahNumber';

    if (bookmarkSet.contains(bookmarkKey)) {
      bookmarkSet.remove(bookmarkKey);
      final result = await _prefs.setStringList(
        _bookmarksKey,
        bookmarkSet.toList(),
      );
      if (result) {
        _notifyChange();
      }
      return result;
    }
    return true;
  }

  /// Check if an ayah is bookmarked (O(1) lookup)
  bool isBookmarked(int surahNumber, int ayahNumber) {
    final bookmarkSet = _getBookmarkSet();
    final bookmarkKey = '$surahNumber:$ayahNumber';
    return bookmarkSet.contains(bookmarkKey);
  }

  /// Toggle bookmark state
  Future<bool> toggleBookmark(int surahNumber, int ayahNumber) async {
    if (isBookmarked(surahNumber, ayahNumber)) {
      return await removeBookmark(surahNumber, ayahNumber);
    } else {
      return await addBookmark(surahNumber, ayahNumber);
    }
  }

  /// Clear all bookmarks
  Future<bool> clearAllBookmarks() async {
    final result = await _prefs.remove(_bookmarksKey);
    if (result) {
      _cachedBookmarks = {};
      _notifyChange();
    }
    return result;
  }

  /// Notify listeners that bookmarks have changed
  void _notifyChange() {
    _ref.read(bookmarksStateProvider.notifier).state++;
  }
}
