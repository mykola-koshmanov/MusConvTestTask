import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../music_parser/parse_exception.dart';
import '../music_parser/parse_failure.dart';
import '../music_parser/rakuten_music_repository.dart';
import 'parse_state.dart';

final rakutenMusicRepositoryProvider = Provider<RakutenMusicRepository>(
  (ref) => RakutenMusicRepository(),
);

final urlInputControllerProvider =
    NotifierProvider<UrlInputController, ParseState>(UrlInputController.new);

class UrlInputController extends Notifier<ParseState> {
  @override
  ParseState build() => const ParseInitial();

  Future<void> submit(String rawUrl) async {
    if (state is ParseLoading) {
      return;
    }
    state = const ParseLoading();
    try {
      final collection = await ref
          .read(rakutenMusicRepositoryProvider)
          .loadCollection(rawUrl);
      state = ParseSuccess(collection);
    } on ParseException catch (exception) {
      state = ParseFailureState(exception.failure);
    } catch (_) {
      state = const ParseFailureState(ParsingFailure());
    }
  }

  void reset() {
    state = const ParseInitial();
  }
}
