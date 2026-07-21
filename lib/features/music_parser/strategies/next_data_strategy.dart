import 'dart:convert';

import 'package:html/dom.dart';

import '../models/music_collection.dart';
import '../models/music_track.dart';
import '../parse_exception.dart';
import '../parse_failure.dart';
import '../rakuten_link.dart';
import '../track_duration.dart';
import 'parse_strategy.dart';

class NextDataStrategy extends ParseStrategy {
  const NextDataStrategy();

  @override
  MusicCollection? extract(Document document, RakutenLink link) {
    final node = document.querySelector('script#__NEXT_DATA__');
    final raw = node?.text;
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }

    final apiResponse = _asMap(
      _dig(decoded, const ['props', 'pageProps', 'apiResponse']),
    );
    final status = _asString(apiResponse?['status']);
    if (status != null && status.toUpperCase() == 'ERROR') {
      throw const ParseException(CollectionNotFoundFailure());
    }

    final dataMap = _asMap(apiResponse?['data']);
    if (dataMap == null) {
      return null;
    }

    final title = _asString(dataMap['name']);
    if (title == null) {
      return null;
    }

    return MusicCollection(
      sourceUrl: link.normalizedUrl,
      sourceId: link.sourceId,
      collectionType: link.collectionType,
      title: title,
      artistName: _asString(_asMap(dataMap['artist'])?['name']),
      imageUrl: _pickImage(dataMap['images']),
      description: _asString(dataMap['review']),
      releaseYear: _asInt(dataMap['release_year']),
      trackCount: _asInt(dataMap['song_count']),
      tracks: _parseTracks(dataMap['songs']),
    );
  }

  List<MusicTrack> _parseTracks(Object? value) {
    final songs = _asList(value);
    if (songs == null) {
      return const [];
    }

    final tracks = <MusicTrack>[];
    for (var index = 0; index < songs.length; index++) {
      final song = _asMap(songs[index]);
      if (song == null) {
        continue;
      }
      final title = _asString(song['name']);
      if (title == null) {
        continue;
      }
      final durationText = _asString(song['time']);
      tracks.add(
        MusicTrack(
          position: index + 1,
          title: title,
          duration: parseClockDuration(durationText),
          durationText: durationText,
        ),
      );
    }
    return tracks;
  }

  String? _pickImage(Object? value) {
    final images = _asList(value);
    if (images == null || images.isEmpty) {
      return null;
    }
    final first = _asMap(images.first);
    if (first == null) {
      return null;
    }
    for (final key in const ['l2', 'l1', 's2', 's1']) {
      final url = _asString(first[key]);
      if (url != null) {
        return url;
      }
    }
    return null;
  }

  Object? _dig(Object? root, List<String> keys) {
    Object? current = root;
    for (final key in keys) {
      final map = _asMap(current);
      if (map == null) {
        return null;
      }
      current = map[key];
    }
    return current;
  }

  Map<String, Object?>? _asMap(Object? value) {
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    return null;
  }

  List<Object?>? _asList(Object? value) {
    if (value is List) {
      return value;
    }
    return null;
  }

  String? _asString(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }
}
