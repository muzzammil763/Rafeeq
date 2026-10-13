import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuranSearchState {
  final bool isSearchActive;
  final String searchQuery;

  const QuranSearchState({this.isSearchActive = false, this.searchQuery = ''});

  QuranSearchState copyWith({bool? isSearchActive, String? searchQuery}) {
    return QuranSearchState(
      isSearchActive: isSearchActive ?? this.isSearchActive,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class QuranSearchNotifier extends Notifier<QuranSearchState> {
  @override
  QuranSearchState build() {
    return const QuranSearchState();
  }

  void toggleSearch() {
    state = state.copyWith(isSearchActive: !state.isSearchActive);
    if (!state.isSearchActive) {
      // Clear query when closing search
      state = state.copyWith(searchQuery: '');
    }
  }

  void updateQuery(String newQuery) {
    state = state.copyWith(searchQuery: newQuery);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void closeSearch() {
    state = const QuranSearchState();
  }
}

final quranSearchProvider =
    NotifierProvider<QuranSearchNotifier, QuranSearchState>(
      () => QuranSearchNotifier(),
    );
