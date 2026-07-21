import 'package:html/dom.dart';

import '../models/music_collection.dart';
import '../rakuten_link.dart';

abstract class ParseStrategy {
  const ParseStrategy();

  MusicCollection? extract(Document document, RakutenLink link);
}
