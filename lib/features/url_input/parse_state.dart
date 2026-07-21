import 'package:flutter/foundation.dart';

import '../music_parser/models/music_collection.dart';
import '../music_parser/parse_failure.dart';

@immutable
sealed class ParseState {
  const ParseState();
}

class ParseInitial extends ParseState {
  const ParseInitial();
}

class ParseLoading extends ParseState {
  const ParseLoading();
}

class ParseSuccess extends ParseState {
  const ParseSuccess(this.collection);

  final MusicCollection collection;
}

class ParseFailureState extends ParseState {
  const ParseFailureState(this.failure);

  final ParseFailure failure;
}
