import 'package:html/parser.dart' as html_parser;

import 'models/music_collection.dart';
import 'parse_exception.dart';
import 'parse_failure.dart';
import 'rakuten_link.dart';
import 'strategies/json_ld_strategy.dart';
import 'strategies/next_data_strategy.dart';
import 'strategies/open_graph_strategy.dart';
import 'strategies/parse_strategy.dart';

class MusicPageParser {
  const MusicPageParser({this.strategies = _defaultStrategies});

  static const List<ParseStrategy> _defaultStrategies = [
    NextDataStrategy(),
    JsonLdStrategy(),
    OpenGraphStrategy(),
  ];

  final List<ParseStrategy> strategies;

  MusicCollection parse(String html, RakutenLink link) {
    if (html.trim().isEmpty) {
      throw const ParseException(CollectionNotFoundFailure());
    }

    final document = html_parser.parse(html);
    for (final strategy in strategies) {
      final result = strategy.extract(document, link);
      if (result != null) {
        return result;
      }
    }
    throw const ParseException(CollectionNotFoundFailure());
  }
}
