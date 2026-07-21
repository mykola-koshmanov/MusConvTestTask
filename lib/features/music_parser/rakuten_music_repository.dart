import 'models/music_collection.dart';
import 'music_page_parser.dart';
import 'parse_exception.dart';
import 'rakuten_page_client.dart';
import 'rakuten_url_validator.dart';

class RakutenMusicRepository {
  RakutenMusicRepository({
    RakutenPageClient? client,
    MusicPageParser? parser,
    RakutenUrlValidator validator = const RakutenUrlValidator(),
  }) : _client = client ?? RakutenPageClient(),
       _parser = parser ?? const MusicPageParser(),
       _validator = validator;

  final RakutenPageClient _client;
  final MusicPageParser _parser;
  final RakutenUrlValidator _validator;

  Future<MusicCollection> loadCollection(String rawUrl) async {
    final validation = _validator.validate(rawUrl);
    switch (validation) {
      case InvalidRakutenUrl(:final failure):
        throw ParseException(failure);
      case ValidRakutenUrl(:final link):
        final html = await _client.fetchHtml(link.normalizedUrl);
        return _parser.parse(html, link);
    }
  }
}
