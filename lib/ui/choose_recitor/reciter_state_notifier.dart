import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:rafeeq/data/reciters_list.dart';
import 'package:rafeeq/data/repo/recitors_repo.dart';

final reciterStateNotifierProvider =
    StateNotifierProvider.autoDispose<ReciterStateNotifier, ReciterState>((
      ref,
    ) {
      final repo = ref.watch(recitersRepoProvider);
      return ReciterStateNotifier(repo);
    });

class ReciterState extends Equatable {
  final Reciter reciter;
  final SurahReciter surahReciter;

  const ReciterState(this.reciter, this.surahReciter);

  @override
  List<Object?> get props => [reciter, surahReciter];

  ReciterState copyWith({Reciter? reciter, SurahReciter? surahReciter}) {
    return ReciterState(
      reciter ?? this.reciter,
      surahReciter ?? this.surahReciter,
    );
  }
}

class ReciterStateNotifier extends StateNotifier<ReciterState> {
  ReciterStateNotifier(this._repo)
    : super(ReciterState(kAllRecitersList.first, SurahReciter.values.first)) {
    _subscriptions.addAll([
      _repo.getReciterStream().listen((event) {
        state = state.copyWith(reciter: event);
      }),
      _repo.getSurahReciterStream().listen((event) {
        state = state.copyWith(surahReciter: event);
      }),
    ]);
  }

  final RecitersRepo _repo;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void dispose() {
    for (var element in _subscriptions) {
      element.cancel();
    }
    super.dispose();
  }
}
