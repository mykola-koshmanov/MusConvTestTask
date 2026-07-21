import 'package:html/dom.dart';

import '../models/music_collection.dart';
import '../rakuten_link.dart';
import 'parse_strategy.dart';

class OpenGraphStrategy extends ParseStrategy {
  const OpenGraphStrategy();

  @override
  MusicCollection? extract(Document document, RakutenLink link) {
    final title = _metaContent(document, 'og:title') ??
        document.querySelector('title')?.text.trim();
    if (title == null || title.isEmpty) {
      return null;
    }

    return MusicCollection(
      sourceUrl: link.normalizedUrl,
      sourceId: link.sourceId,
      collectionType: link.collectionType,
      title: _cleanTitle(title),
      imageUrl: _metaContent(document, 'og:image'),
    );
  }

  String _cleanTitle(String title) {
    const separators = [' | ', ' - '];
    for (final separator in separators) {
      if (title.contains(separator)) {
        final segments = title.split(separator);
        return segments.last.trim();
      }
    }
    return title.trim();
  }

  String? _metaContent(Document document, String property) {
    final element =
        document.querySelector('meta[property="$property"]') ??
        document.querySelector('meta[name="$property"]');
    final content = element?.attributes['content']?.trim();
    if (content == null || content.isEmpty) {
      return null;
    }
    return content;
  }
}
